#!/usr/bin/env bash
# Scan git content for secrets, keys, and PII.
#
# Usage:
#   scan-secrets.sh          scan lines added in the staged diff (pre-commit)
#   scan-secrets.sh --all    scan every tracked file
#
# Allow one line: put "secret-scan:allow" anywhere on it.
# Skip the whole check: git commit --no-verify
set -uo pipefail

ALLOW_MARKER='secret-scan:allow'

mode='staged'
[ "${1:-}" = '--all' ] && mode='all'

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
meta_file="$work_dir/meta"       # one "path<TAB>line" per scanned line
content_file="$work_dir/content" # the scanned line text, same order as meta_file
: >"$meta_file"
: >"$content_file"

# Rules: "name<TAB>flags<TAB>extended regex". flags is "-" or "i" (case-insensitive).
# Reason: plain POSIX ERE (no \b, \s, \d) so BSD grep, GNU grep and ugrep all agree.
RULES="$(cat <<'EOF'
Private key block	-	-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY( BLOCK)?-----
AWS access key id	-	(^|[^A-Z0-9])(AKIA|ASIA|ABIA|ACCA)[A-Z0-9]{16}([^A-Z0-9]|$)
AWS secret access key	i	aws_?secret_?access_?key["']?[[:space:]]*[:=][[:space:]]*["']?[A-Za-z0-9/+]{40}
GitHub token	-	(gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{60,})
GitLab token	-	glpat-[A-Za-z0-9_-]{20,}
Slack token	-	xox[abposr]-[A-Za-z0-9-]{10,}
Slack webhook	-	hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[A-Za-z0-9]+
Google API key	-	AIza[0-9A-Za-z_-]{35}
Stripe live key	-	(sk|rk)_live_[0-9A-Za-z]{24,}
Anthropic API key	-	sk-ant-[A-Za-z0-9_-]{20,}
OpenAI API key	-	sk-(proj-)?[A-Za-z0-9_-]{20,}T3BlbkFJ[A-Za-z0-9_-]{20,}
npm token	-	npm_[A-Za-z0-9]{36}
JSON web token	-	eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}
Credentials in URL	i	[a-z][a-z0-9+.-]*://[^/[:space:]:@"']+:[^/[:space:]@"'$]{3,}@[a-z0-9.-]+
Hardcoded secret	i	(password|passwd|pwd|secret|token|api_?key|apikey|access_?key|client_?secret|auth_?key)[a-z0-9_-]*["']?[[:space:]]*[:=][[:space:]]*["'][^"'[:space:]$]{8,}["']
US SSN	-	(^|[^0-9-])[0-9]{3}-[0-9]{2}-[0-9]{4}([^0-9-]|$)
Credit card number	-	(^|[^0-9])(4[0-9]{3}|5[1-5][0-9]{2}|3[47][0-9]{2}|6011)([ -]?[0-9]{4}){3}([^0-9]|$)
Email address	i	[a-z0-9._%+-]+@[a-z0-9-]+(\.[a-z0-9-]+)*\.[a-z]{2,}
EOF
)"

# Reason: these hits match the email rule but are not personal data.
EMAIL_SAFE_REGEX='@(example\.(com|org|net)|[a-z0-9.-]*\.(test|example|invalid|localhost)|users\.noreply\.github\.com|anthropic\.com)|noreply@|no-reply@|git@'

# Files that must never be committed, whatever they contain.
BLOCKED_PATH_REGEX='(^|/)(\.env(\.[^/]*)?|id_(rsa|dsa|ecdsa|ed25519)|[^/]*\.(pem|key|p12|pfx|jks|keystore|ppk|kdbx)|\.netrc|\.pgpass|\.htpasswd|credentials(\.json)?|\.aws/credentials|\.mylogin\.cnf|kubeconfig)$'
BLOCKED_PATH_SAFE_REGEX='(^|/)\.env\.(example|sample|template)$|\.pub$'

collect_staged() {
  git diff --cached --name-only --diff-filter=ACMR -z >"$work_dir/paths"
  # Reason: -U0 gives only the added lines, so old content already in history does not block new commits.
  git -c core.quotePath=false diff --cached -U0 --no-color --no-ext-diff --diff-filter=ACMR |
    awk -v meta="$meta_file" -v content="$content_file" -v marker="$ALLOW_MARKER" '
      # Reason: git appends a tab to "+++ b/<path>" when the path contains a space.
      /^\+\+\+ / { path = substr($0, 7); sub(/\t$/, "", path); next }
      /^@@ / {
        match($0, /\+[0-9]+/)
        line_number = substr($0, RSTART + 1, RLENGTH - 1) + 0
        next
      }
      /^\+/ {
        text = substr($0, 2)
        if (index(text, marker) == 0) {
          print path "\t" line_number >meta
          print text >content
        }
        line_number++
      }
    '
}

collect_all() {
  git ls-files -z >"$work_dir/paths"
  # Reason: git grep -I lists only text files, and one awk pass is far faster than a loop per file.
  # Reason: ">>" because xargs can start awk more than once, and ">" would truncate the earlier output.
  git -c core.quotePath=false grep -I -l -z -e '' |
    xargs -0 awk -v meta="$meta_file" -v content="$content_file" -v marker="$ALLOW_MARKER" '
      index($0, marker) == 0 {
        print FILENAME "\t" FNR >>meta
        print $0 >>content
      }
    '
}

if [ "$mode" = 'all' ]; then
  collect_all
else
  collect_staged
fi

findings_file="$work_dir/findings"
: >"$findings_file"

while IFS= read -r path; do
  [ -n "$path" ] || continue
  printf '%s\n' "$path" | grep -Eiq "$BLOCKED_PATH_SAFE_REGEX" && continue
  printf '%s\n' "$path" | grep -Eiq "$BLOCKED_PATH_REGEX" || continue
  printf '%s\t-\tSensitive file name\n' "$path" >>"$findings_file"
done < <(tr '\0' '\n' <"$work_dir/paths")

while IFS=$'\t' read -r rule_name rule_flags rule_regex; do
  [ -n "$rule_name" ] || continue
  grep_flags='-nE'
  [ "$rule_flags" = 'i' ] && grep_flags='-niE'

  matched_lines="$(grep $grep_flags -e "$rule_regex" "$content_file" 2>/dev/null)"
  if [ "$rule_name" = 'Email address' ] && [ -n "$matched_lines" ]; then
    matched_lines="$(printf '%s\n' "$matched_lines" | grep -viE -e "$EMAIL_SAFE_REGEX")"
  fi
  [ -n "$matched_lines" ] || continue

  # Reason: map content line numbers back to "path<TAB>line" without printing the secret itself.
  printf '%s\n' "$matched_lines" | cut -d: -f1 |
    awk -v rule="$rule_name" 'NR == FNR { hit[$1] = 1; next } (FNR in hit) { print $0 "\t" rule }' - "$meta_file" \
      >>"$findings_file"
done <<<"$RULES"

[ -s "$findings_file" ] || exit 0

finding_count="$(wc -l <"$findings_file" | tr -d ' ')"
{
  printf '\n\033[31msecret-scan: %s possible secret or PII finding(s)\033[0m\n\n' "$finding_count"
  sort -t$'\t' -k1,1 -k2,2n "$findings_file" |
    awk -F'\t' '{ location = ($2 == "-") ? $1 : $1 ":" $2; printf "  %-60s %s\n", location, $3 }'
  printf '\nFix the lines above, or:\n'
  printf '  - add "%s" to a line that is a false positive\n' "$ALLOW_MARKER"
  printf '  - run "git commit --no-verify" to skip this check\n\n'
} >&2

# Reason: in --all mode the report is the goal, so findings do not count as a failure of the script.
[ "$mode" = 'all' ] && exit 0
exit 1
