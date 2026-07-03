#!/bin/sh
# Self-contained demo test runner for the BWI Test Hub.
#
# Deliberately dependency-free (POSIX sh only): it runs a handful of
# trivial "test cases", writes a JUnit XML and a small HTML report into
# report/, and exits non-zero if any case fails — so the hub shows a
# green run out of the box and a red one if you flip a case to fail.
set -eu

REPORT_DIR="report"
mkdir -p "$REPORT_DIR"

pass=0
fail=0
cases=""

# check <name> <actual> <expected>
check() {
  name="$1"; actual="$2"; expected="$3"
  if [ "$actual" = "$expected" ]; then
    pass=$((pass + 1))
    cases="${cases}    <testcase classname=\"demo\" name=\"${name}\" time=\"0.001\"/>\n"
    echo "PASS ${name}"
  else
    fail=$((fail + 1))
    cases="${cases}    <testcase classname=\"demo\" name=\"${name}\" time=\"0.001\">\n      <failure message=\"expected ${expected}, got ${actual}\"/>\n    </testcase>\n"
    echo "FAIL ${name}: expected ${expected}, got ${actual}"
  fi
}

# --- the "test suite" -----------------------------------------------
check "addition"        "$((2 + 2))"          "4"
check "string-compare"  "bwi-test-hub"        "bwi-test-hub"
check "uppercase"       "$(echo hub | tr a-z A-Z)" "HUB"
# Flip the next expected value to "999" to see a failing run in the hub.
check "line-count"      "$(printf 'a\nb\nc\n' | wc -l | tr -d ' ')" "3"

total=$((pass + fail))

# --- JUnit XML ------------------------------------------------------
{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  printf '<testsuite name="bwi-test-hub-demo" tests="%s" failures="%s" time="0.01">\n' "$total" "$fail"
  printf "%b" "$cases"
  echo '</testsuite>'
} > "$REPORT_DIR/junit.xml"

# --- HTML report ----------------------------------------------------
status_text="PASSED"
status_color="#16a34a"
[ "$fail" -eq 0 ] || { status_text="FAILED"; status_color="#dc2626"; }

{
  echo '<!doctype html><html lang="en"><head><meta charset="utf-8">'
  echo '<title>BWI Test Hub — Demo Report</title>'
  echo '<style>body{font-family:system-ui,sans-serif;margin:2rem;background:#0f172a;color:#e2e8f0}'
  echo 'h1{margin:0 0 .25rem}.badge{display:inline-block;padding:.2rem .8rem;border-radius:999px;color:#fff;font-weight:700}'
  echo 'table{border-collapse:collapse;margin-top:1rem;width:100%}td,th{padding:.5rem .8rem;border-bottom:1px solid #334155;text-align:left}'
  echo '.ok{color:#4ade80}.no{color:#f87171}</style></head><body>'
  printf '<h1>bwi-test-hub-demo</h1>\n'
  printf '<p>Run status: <span class="badge" style="background:%s">%s</span> &middot; %s of %s passed</p>\n' \
      "$status_color" "$status_text" "$pass" "$total"
  echo '<table><tr><th>#</th><th>Test case</th><th>Result</th></tr>'
  printf "%b" "$cases" | grep 'testcase' | awk -F'name="' '{print $2}' | awk -F'"' '{print $1}' | \
    while IFS= read -r n; do
      printf '<tr><td></td><td>%s</td><td class="ok">passed</td></tr>\n' "$n"
    done
  echo '</table></body></html>'
} > "$REPORT_DIR/index.html"

echo ""
echo "Summary: ${pass}/${total} passed, ${fail} failed"
[ "$fail" -eq 0 ]
