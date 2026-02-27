#!/usr/bin/env bash
# Fetch adoption metrics from ClawHub API for published skills
# Usage: skill-stats.sh
# Requires network access. Saves snapshots to .workbench-cache/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

CACHE_DIR="$REPO_ROOT/.workbench-cache"
mkdir -p "$CACHE_DIR"

API_BASE="https://clawdhub.com/api/v1/skills"
TODAY=$(date +%Y%m%d)
SNAPSHOT_FILE="$CACHE_DIR/stats-${TODAY}.json"

log_header "ClawHub Skill Stats"

# Collect all our skill slugs
skills=()
while IFS= read -r dir; do
  skills+=("$(get_skill_slug "$dir")")
done < <(discover_skills "$REPO_ROOT/skills")

echo "Fetching stats for ${#skills[@]} skills..."
echo ""

# Table header
printf "  %-24s %10s %6s %10s\n" "Skill" "Downloads" "Stars" "Installs"
printf "  %-24s %10s %6s %10s\n" "------------------------" "----------" "------" "----------"

results="[]"

for slug in "${skills[@]}"; do
  # Skip coding-agent (not ours)
  [[ "$slug" == "coding-agent" ]] && continue

  # Fetch from API
  response=$(curl -sf "${API_BASE}/${slug}" 2>/dev/null || echo '{}')

  downloads=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('downloads','-'))" 2>/dev/null || echo "-")
  stars=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stars','-'))" 2>/dev/null || echo "-")
  installs=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('installs','-'))" 2>/dev/null || echo "-")

  printf "  %-24s %10s %6s %10s\n" "$slug" "$downloads" "$stars" "$installs"

  # Accumulate JSON
  results=$(echo "$results" | python3 -c "
import sys, json
arr = json.load(sys.stdin)
arr.append({'slug': '$slug', 'downloads': '$downloads', 'stars': '$stars', 'installs': '$installs'})
print(json.dumps(arr))
" 2>/dev/null || echo "$results")
done

# Save snapshot
echo "$results" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin), indent=2))" > "$SNAPSHOT_FILE" 2>/dev/null || true

echo ""
echo "Snapshot saved: $SNAPSHOT_FILE"
echo ""
