#!/usr/bin/env bash
# Scanner self-test — validates detection accuracy using fixture files
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCANNER="$REPO_ROOT/tools/skill-scan.sh"

PASS=0
FAIL=0
ERRORS=()

# Create temporary skill directories from fixture files
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

setup_fixture() {
  local name="$1" fixture="$2"
  mkdir -p "$TMPDIR/$name"
  cp "$fixture" "$TMPDIR/$name/SKILL.md"
}

setup_fixture "known-bad" "$SCRIPT_DIR/known-bad.md"
setup_fixture "known-clean" "$SCRIPT_DIR/known-clean.md"
setup_fixture "allowlisted" "$SCRIPT_DIR/allowlisted.md"
# Copy .scanignore for allowlisted fixture
cp "$SCRIPT_DIR/.scanignore" "$TMPDIR/allowlisted/.scanignore"

echo ""
echo "=== Scanner Self-Test ==="
echo ""

# ── Test 1: known-bad must produce findings across all categories ──
echo -n "Test 1: known-bad detects findings... "
json_output=$("$SCANNER" --json "$TMPDIR/known-bad" 2>/dev/null || true)
total=$(echo "$json_output" | python3 -c "import sys,json; print(json.load(sys.stdin)['summary']['total'])" 2>/dev/null || \
        echo "$json_output" | python -c "import sys,json; print(json.load(sys.stdin)['summary']['total'])" 2>/dev/null)

if (( total >= 10 )); then
  echo "PASS ($total findings)"
  PASS=$((PASS + 1))
else
  echo "FAIL (expected >=10, got $total)"
  FAIL=$((FAIL + 1))
  ERRORS+=("known-bad: expected >=10 findings, got $total")
fi

# ── Test 2: known-bad covers multiple categories ──
echo -n "Test 2: known-bad covers multiple categories... "
py_cmd='import sys,json; cats=set(f["category"] for f in json.load(sys.stdin)["findings"]); print(len(cats))'
categories=$(echo "$json_output" | python3 -c "$py_cmd" 2>/dev/null || \
             echo "$json_output" | python -c "$py_cmd" 2>/dev/null)

if (( categories >= 8 )); then
  echo "PASS ($categories categories)"
  PASS=$((PASS + 1))
else
  echo "FAIL (expected >=8 categories, got $categories)"
  FAIL=$((FAIL + 1))
  ERRORS+=("known-bad: expected >=8 categories, got $categories")
fi

# ── Test 3: known-clean produces zero findings ──
echo -n "Test 3: known-clean has zero findings... "
json_output=$("$SCANNER" --json "$TMPDIR/known-clean" 2>/dev/null)
total=$(echo "$json_output" | python3 -c "import sys,json; print(json.load(sys.stdin)['summary']['total'])" 2>/dev/null || \
        echo "$json_output" | python -c "import sys,json; print(json.load(sys.stdin)['summary']['total'])" 2>/dev/null)

if (( total == 0 )); then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (expected 0, got $total)"
  FAIL=$((FAIL + 1))
  ERRORS+=("known-clean: expected 0 findings, got $total")
fi

# ── Test 4: allowlisted findings are all suppressed ──
echo -n "Test 4: allowlisted has zero effective findings... "
json_output=$("$SCANNER" --json "$TMPDIR/allowlisted" 2>/dev/null)
total=$(echo "$json_output" | python3 -c "import sys,json; print(json.load(sys.stdin)['summary']['total'])" 2>/dev/null || \
        echo "$json_output" | python -c "import sys,json; print(json.load(sys.stdin)['summary']['total'])" 2>/dev/null)

if (( total == 0 )); then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (expected 0, got $total — scanignore not working)"
  FAIL=$((FAIL + 1))
  ERRORS+=("allowlisted: expected 0 findings, got $total")
fi

# ── Test 5: JSON output is valid and has required fields ──
echo -n "Test 5: JSON output has required fields... "
py_check='import sys,json; d=json.load(sys.stdin); assert "scanner" in d; assert "summary" in d; assert "findings" in d; assert "blocked" in d; print("OK")'
result=$(echo "$json_output" | python3 -c "$py_check" 2>/dev/null || \
         echo "$json_output" | python -c "$py_check" 2>/dev/null || echo "ERROR")

if [[ "$result" == "OK" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (missing required JSON fields)"
  FAIL=$((FAIL + 1))
  ERRORS+=("JSON structure: missing required fields")
fi

# ── Summary ──
echo ""
echo "Self-Test Results: $PASS passed, $FAIL failed"

if (( FAIL > 0 )); then
  echo ""
  echo "Failures:"
  for e in "${ERRORS[@]}"; do
    echo "  - $e"
  done
  exit 1
fi
