#!/usr/bin/env bash
# Imports the APEXlang source in this checkout into APP_ID. No checks.
#   APP_ID, APP_ALIAS, APP_NAME   the APEX app to deploy to
#   SQLCL_BIN, DB_WALLET_ZIP, DB_SERVICE, DB_USER, DB_PASSWORD  (setup-sqlcl action)
set -euo pipefail

: "${APP_ID:?}" "${APP_ALIAS:?}" "${APP_NAME:?}"
# workspace-components are not deployed: they already live in the workspace (shared with
# other apps) and SQLcl rejects some of them, e.g. the CLAUDE Generative AI provider.
APP_PATHS=(.apex application.apx deployments developer-comments.apx page-groups.apx
           pages shared-components supporting-objects)
OUT=build
rm -rf "$OUT"; mkdir -p "$OUT/src"
OUT=$(cd "$OUT" && pwd)

log()  { printf '\n==> %s\n' "$*"; }
fail() { printf '::error::%s\n' "$*"; exit 1; }
native_path() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi; }

# Runs SQLcl commands from stdin, saving output to $1. Password goes via stdin.
run_sql() {
  local out=$1 rc=0
  {
    printf 'set cloudconfig %s\n' "$(native_path "$DB_WALLET_ZIP")"
    printf 'connect %s/"%s"@%s\n' "$DB_USER" "$DB_PASSWORD" "$DB_SERVICE"
    cat
    printf 'exit\n'
  } | MSYS_NO_PATHCONV=1 timeout -k 30s 20m "$SQLCL_BIN" -S -L /nolog 2>&1 | tee "$out" || rc=${PIPESTATUS[1]}
  [ "$rc" -ne 124 ] || fail "SQLcl timed out."
  if grep -qE 'Connection failed|Not connected|SP2-0640|ORA-01017|ORA-12506|ORA-12170' "$out"; then
    fail "Could not connect to the database. Check the DB_* secrets and the database access list."
  fi
}

for p in "${APP_PATHS[@]}"; do [ -e "$p" ] && cp -a "$p" "$OUT/src/"; done
[ -f "$OUT/src/application.apx" ] || fail "application.apx not found in the repo root."

log "Import into app $APP_ID ($APP_ALIAS)"
who=$(printf '%s' "${CHANGED_BY:-unknown}" | tr -cd 'A-Za-z0-9_.[]-')
version="main $(git rev-parse --short HEAD) $(date -u '+%Y-%m-%d %H:%M') UTC"
# set_keep_sessions: don't log users out on every deploy.
# The stamp afterwards fills "Updated By" (GITHUB:<user>) and Version in App Builder.
run_sql "$OUT/import.log" <<SQL
exec apex_application_install.set_keep_sessions(p_keep_sessions => true)
apex import -input "$(native_path "$OUT/src")" -id $APP_ID -alias $APP_ALIAS -name "$APP_NAME"
declare
  l_workspace apex_applications.workspace%type;
begin
  select workspace into l_workspace from apex_applications where application_id = $APP_ID;
  apex_util.set_workspace(l_workspace);
  apex_application.g_user := 'GITHUB:$who';
  apex_application_admin.set_application_version(p_application_id => $APP_ID, p_version => '$version');
  commit;
end;
/
SQL
grep -q 'Import successful' "$OUT/import.log" || fail "Import did not report success. See the log above."

echo "Deployed $(git rev-parse --short HEAD) to app $APP_ID."
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  printf '### Deployed `%s` to app %s (%s)\n\nVersion `%s`, Updated By `GITHUB:%s`\n' \
    "$(git rev-parse --short HEAD)" "$APP_ID" "$APP_NAME" "$version" "$who" >> "$GITHUB_STEP_SUMMARY"
fi
