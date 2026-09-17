#!/bin/sh
# corpus-admission.sh — the guard every load-bearing row's `wire_back` points at.
# Ships INSIDE the artifact (path-free: resolves from its own location), so a stranger can run
# it: every pillar file non-empty, zero placeholders, one ADMIT verdict per row and no REJECT,
# and every load-bearing row's wire_back names a file that exists here. --selftest plants a
# REJECT verdict into a temp copy and asserts the guard catches it.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT="${1:-$HERE/..}"

check() {
  root="$1"; rows="$root/rows"
  [ -d "$rows" ] || { echo "RED: no rows/ under $root"; return 1; }
  for p in p1 p2 p3 p4; do
    [ -s "$rows/$p.jsonl" ] || { echo "RED: $p.jsonl empty/missing"; return 1; }
  done
  if grep -rIq -e PLACEHOLDER -e TODO_FILL "$rows/" 2>/dev/null; then echo "RED: placeholder rows"; return 1; fi
  adm="$rows/admission.jsonl"
  [ -s "$adm" ] || { echo "RED: no admission.jsonl (gate skipped)"; return 1; }
  if grep -q '"verdict"[ ]*:[ ]*"REJECT"' "$adm"; then echo "RED: REJECT verdict present"; return 1; fi
  n_rows=$(cat "$rows"/p1.jsonl "$rows"/p2.jsonl "$rows"/p3.jsonl "$rows"/p4.jsonl | grep -c . || echo 0)
  n_adm=$(grep -c '"verdict"[ ]*:[ ]*"ADMIT"' "$adm" || echo 0)
  [ "$n_adm" -ge "$n_rows" ] || { echo "RED: admitted $n_adm < rows $n_rows"; return 1; }
  # every load-bearing row's wire_back must exist inside the artifact
  missing=$(python3 - "$root" <<'PY'
import json, os, sys
root = sys.argv[1]; bad = 0
for p in ("p1", "p2", "p3", "p4"):
    for ln in open(os.path.join(root, "rows", f"{p}.jsonl")):
        r = json.loads(ln)
        if r.get("load_bearing") and not os.path.isfile(os.path.join(root, r.get("wire_back") or "")):
            bad += 1
print(bad)
PY
)
  [ "$missing" -eq 0 ] || { echo "RED: $missing load-bearing row(s) name a wire_back that does not exist"; return 1; }
  echo "GREEN: rows=$n_rows admitted=$n_adm wire_backs=present"
}

selftest() {
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  mkdir -p "$tmp/rows" "$tmp/guards"; cp "$0" "$tmp/guards/corpus-admission.sh"
  for p in p1 p2 p3 p4; do
    echo '{"eq_hash":"h","pillar":"'$p'","load_bearing":true,"wire_back":"guards/corpus-admission.sh"}' > "$tmp/rows/$p.jsonl"
    echo '{"verdict":"ADMIT"}' >> "$tmp/rows/admission.jsonl"
  done
  check "$tmp" >/dev/null || { echo "SELFTEST FAIL: clean artifact not GREEN"; return 1; }
  echo '{"verdict":"REJECT"}' >> "$tmp/rows/admission.jsonl"
  check "$tmp" >/dev/null 2>&1 && { echo "SELFTEST FAIL: planted REJECT not caught"; return 1; }
  sed -i.bak '$d' "$tmp/rows/admission.jsonl"
  echo '{"eq_hash":"x","pillar":"p4","load_bearing":true,"wire_back":"guards/nope.sh"}' >> "$tmp/rows/p4.jsonl"
  echo '{"verdict":"ADMIT"}' >> "$tmp/rows/admission.jsonl"
  check "$tmp" >/dev/null 2>&1 && { echo "SELFTEST FAIL: dead wire_back not caught"; return 1; }
  echo "SELFTEST PASS (clean=GREEN; planted REJECT caught; dead wire_back caught)"
}

case "${1:-}" in
  --selftest) selftest ;;
  *) check "$ROOT" ;;
esac
