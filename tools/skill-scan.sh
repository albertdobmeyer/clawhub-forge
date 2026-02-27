#!/usr/bin/env bash
# Offline security scanner — pattern-based detection without network
# Usage: skill-scan.sh <path>  (path = skills/ dir or single skill dir)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/patterns.sh"

TARGET="${1:-skills}"

log_header "Security scanning: $TARGET"

skills=()
while IFS= read -r dir; do
  skills+=("$dir")
done < <(discover_skills "$TARGET")

if (( ${#skills[@]} == 0 )); then
  echo "No skills found in $TARGET"
  exit 1
fi

CRITICAL_COUNT=0
HIGH_COUNT=0
FINDING_COUNT=0

# Check if a line should be ignored via inline comment or .scanignore
is_ignored() {
  local file="$1" line_num="$2" skill_dir="$3"
  local line
  line=$(sed -n "${line_num}p" "$file")

  # Check inline ignore comment
  if echo "$line" | grep -q '# scan:ignore-next-line\|<!-- scan:ignore -->'; then
    return 0
  fi

  # Check previous line for scan:ignore-next-line
  if (( line_num > 1 )); then
    local prev_line
    prev_line=$(sed -n "$(( line_num - 1 ))p" "$file")
    if echo "$prev_line" | grep -q 'scan:ignore-next-line'; then
      return 0
    fi
  fi

  # Check .scanignore file
  local scanignore="$skill_dir/.scanignore"
  if [[ -f "$scanignore" ]]; then
    while IFS= read -r range; do
      # Skip comments and empty lines
      [[ "$range" =~ ^#.*$ || -z "$range" ]] && continue
      # Support "L10-L20" range format
      if [[ "$range" =~ ^L([0-9]+)-L([0-9]+)$ ]]; then
        local start="${BASH_REMATCH[1]}" end="${BASH_REMATCH[2]}"
        if (( line_num >= start && line_num <= end )); then
          return 0
        fi
      fi
      # Support single line "L10" format
      if [[ "$range" =~ ^L([0-9]+)$ ]]; then
        if (( line_num == BASH_REMATCH[1] )); then
          return 0
        fi
      fi
    done < "$scanignore"
  fi

  return 1
}

for skill_dir in "${skills[@]}"; do
  file="$skill_dir/SKILL.md"
  slug=$(get_skill_slug "$skill_dir")
  skill_findings=0

  for pattern_def in "${SCAN_PATTERNS[@]}"; do
    IFS='|' read -r severity category regex description <<< "$pattern_def"

    # Search for pattern matches with line numbers
    while IFS=: read -r line_num match_line; do
      [[ -z "$line_num" ]] && continue

      # Check if this finding is allowlisted
      if is_ignored "$file" "$line_num" "$skill_dir"; then
        continue
      fi

      if (( skill_findings == 0 )); then
        echo -e "\n${CYAN}--- $slug ---${RESET}"
      fi
      skill_findings=$((skill_findings + 1))
      FINDING_COUNT=$((FINDING_COUNT + 1))

      case "$severity" in
        CRITICAL)
          echo -e "  ${RED}CRITICAL${RESET} [${category}] L${line_num}: ${description}"
          CRITICAL_COUNT=$((CRITICAL_COUNT + 1))
          ;;
        HIGH)
          echo -e "  ${YELLOW}HIGH${RESET}     [${category}] L${line_num}: ${description}"
          HIGH_COUNT=$((HIGH_COUNT + 1))
          ;;
        *)
          echo -e "  ${BLUE}MEDIUM${RESET}   [${category}] L${line_num}: ${description}"
          ;;
      esac

      # Show context (the matching line, truncated)
      context=$(echo "$match_line" | head -c 120)
      echo -e "           ${DIM}${context}${RESET}"

    done < <(grep -nE "$regex" "$file" 2>/dev/null || true)
  done

  if (( skill_findings == 0 )); then
    log_pass "$slug: Clean"
    count_pass
  fi
done

echo ""
echo -e "${BOLD}Scan Results:${RESET}"
echo -e "  Total findings: ${FINDING_COUNT}"
echo -e "  ${RED}Critical: ${CRITICAL_COUNT}${RESET}"
echo -e "  ${YELLOW}High: ${HIGH_COUNT}${RESET}"
echo -e "  ${GREEN}Clean skills: ${PASS_COUNT}${RESET}"
echo ""

if (( CRITICAL_COUNT > 0 )); then
  echo -e "${RED}BLOCKED: ${CRITICAL_COUNT} critical finding(s). Review and allowlist or fix.${RESET}"
  echo "  Use '# scan:ignore-next-line' or a .scanignore file to allowlist expected patterns."
  exit 1
fi
