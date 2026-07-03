#!/bin/sh
# Self-contained demo test runner for the BWI Test Hub.
#
# Deliberately dependency-free (POSIX sh only): it runs a handful of
# trivial "test cases", writes a JUnit XML and a polished, self-contained
# HTML report into report/, and exits non-zero if any case fails — so the
# hub shows a green run out of the box and a red one if you flip a case.
set -eu

REPORT_DIR="report"
mkdir -p "$REPORT_DIR"

started=$(date +%s)
pass=0
fail=0
cases=""       # JUnit <testcase> fragments
html_rows=""   # HTML <tr> fragments

# check <name> <actual> <expected>
check() {
  name="$1"; actual="$2"; expected="$3"
  if [ "$actual" = "$expected" ]; then
    pass=$((pass + 1))
    cases="${cases}    <testcase classname=\"demo\" name=\"${name}\" time=\"0.001\"/>\n"
    html_rows="${html_rows}<tr><td class=\"name\">${name}</td><td><span class=\"chip ok\">&#10003; passed</span></td></tr>"
    echo "PASS ${name}"
  else
    msg="expected ${expected}, got ${actual}"
    fail=$((fail + 1))
    cases="${cases}    <testcase classname=\"demo\" name=\"${name}\" time=\"0.001\">\n      <failure message=\"${msg}\"/>\n    </testcase>\n"
    html_rows="${html_rows}<tr><td class=\"name\">${name}</td><td><span class=\"chip no\">&#10007; failed</span><div class=\"msg\">${msg}</div></td></tr>"
    echo "FAIL ${name}: ${msg}"
  fi
}

# --- the "test suite" -----------------------------------------------
check "addition"        "$((2 + 2))"          "4"
check "string-compare"  "bwi-test-hub"        "bwi-test-hub"
check "uppercase"       "$(echo hub | tr a-z A-Z)" "HUB"
# Flip the next expected value to "999" to see a failing run in the hub.
check "line-count"      "$(printf 'a\nb\nc\n' | wc -l | tr -d ' ')" "3"

total=$((pass + fail))
ended=$(date +%s)
duration=$((ended - started))

# --- JUnit XML ------------------------------------------------------
{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  printf '<testsuite name="bwi-test-hub-demo" tests="%s" failures="%s" time="%s">\n' "$total" "$fail" "$duration"
  printf "%b" "$cases"
  echo '</testsuite>'
} > "$REPORT_DIR/junit.xml"

# --- HTML report ----------------------------------------------------
if [ "$fail" -eq 0 ]; then status="PASSED"; scls="ok"; else status="FAILED"; scls="no"; fi
if [ "$total" -gt 0 ]; then pct=$((pass * 100 / total)); else pct=0; fi
generated=$(date "+%Y-%m-%d %H:%M:%S")

cat > "$REPORT_DIR/index.html" <<EOF
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>shell-posix &mdash; Test Report</title>
<style>
:root{--bg:#0b1120;--panel:#111a2e;--panel2:#0f1728;--border:#1e2a44;--text:#e6ecf7;--muted:#8ea0c0;--ok:#22c55e;--no:#ef4444}
*{box-sizing:border-box}
body{margin:0;font-family:ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;background:radial-gradient(1200px 600px at 20% -10%,#16223f 0%,var(--bg) 55%);color:var(--text);padding:2.5rem 1.25rem;min-height:100vh}
.wrap{max-width:920px;margin:0 auto}
.head{display:flex;align-items:center;gap:1rem;flex-wrap:wrap;justify-content:space-between;margin-bottom:1.75rem}
.title h1{margin:0;font-size:1.6rem;letter-spacing:-.02em}
.title p{margin:.35rem 0 0;color:var(--muted);font-size:.95rem}
.pill{display:inline-flex;align-items:center;gap:.5rem;padding:.5rem 1rem;border-radius:999px;font-weight:700;font-size:.95rem;color:#fff}
.pill.ok{background:linear-gradient(135deg,#16a34a,#22c55e);box-shadow:0 6px 20px -6px rgba(34,197,94,.55)}
.pill.no{background:linear-gradient(135deg,#dc2626,#ef4444);box-shadow:0 6px 20px -6px rgba(239,68,68,.55)}
.dot{width:.6rem;height:.6rem;border-radius:50%;background:#fff}
.cards{display:grid;grid-template-columns:repeat(4,1fr);gap:.9rem;margin-bottom:1.5rem}
.card{background:linear-gradient(180deg,var(--panel),var(--panel2));border:1px solid var(--border);border-radius:14px;padding:1rem 1.1rem}
.card .k{color:var(--muted);font-size:.72rem;text-transform:uppercase;letter-spacing:.08em}
.card .v{font-size:1.7rem;font-weight:700;margin-top:.25rem}
.card.ok .v{color:var(--ok)}.card.no .v{color:var(--no)}
.bar{height:.5rem;border-radius:999px;background:#1e2a44;overflow:hidden;margin-bottom:1.75rem}
.bar>i{display:block;height:100%;background:linear-gradient(90deg,#22c55e,#4ade80)}
table{width:100%;border-collapse:collapse;background:var(--panel);border:1px solid var(--border);border-radius:14px;overflow:hidden}
th,td{padding:.8rem 1rem;text-align:left;font-size:.92rem;vertical-align:top}
thead th{background:#0e1626;color:var(--muted);font-weight:600;text-transform:uppercase;letter-spacing:.06em;font-size:.72rem}
tbody tr{border-top:1px solid var(--border)}
tbody tr:hover{background:#0e1830}
td.name{font-family:ui-monospace,SFMono-Regular,Menlo,monospace}
.chip{display:inline-flex;align-items:center;gap:.4rem;padding:.2rem .6rem;border-radius:999px;font-size:.78rem;font-weight:600}
.chip.ok{color:#bbf7d0;background:#14351f;border:1px solid #1f5133}
.chip.no{color:#fecaca;background:#3a1618;border:1px solid #5b2327}
.msg{color:#fca5a5;font-family:ui-monospace,monospace;font-size:.82rem;margin-top:.35rem}
.foot{color:var(--muted);font-size:.82rem;margin-top:1.25rem;display:flex;justify-content:space-between;flex-wrap:wrap;gap:.5rem}
</style>
</head>
<body>
<div class="wrap">
  <div class="head">
    <div class="title"><h1>shell-posix</h1><p>POSIX shell &middot; BWI Test Hub demo</p></div>
    <span class="pill ${scls}"><span class="dot"></span>${status}</span>
  </div>
  <div class="cards">
    <div class="card"><div class="k">Total</div><div class="v">${total}</div></div>
    <div class="card ok"><div class="k">Passed</div><div class="v">${pass}</div></div>
    <div class="card no"><div class="k">Failed</div><div class="v">${fail}</div></div>
    <div class="card"><div class="k">Duration</div><div class="v">${duration}s</div></div>
  </div>
  <div class="bar"><i style="width:${pct}%"></i></div>
  <table>
    <thead><tr><th>Test</th><th>Result</th></tr></thead>
    <tbody>${html_rows}</tbody>
  </table>
  <div class="foot"><span>Runtime: shell-alpine (container)</span><span>Generated ${generated}</span></div>
</div>
</body>
</html>
EOF

echo ""
echo "Summary: ${pass}/${total} passed, ${fail} failed"
[ "$fail" -eq 0 ]
