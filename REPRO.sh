#!/bin/sh
# REPRO.sh — verify this artifact with nothing but sh + python3. No installs, no network.
set -eu
cd "$(dirname "$0")"
python3 - <<'PY'
import hashlib, json, os, sys
bad = 0
for ln in open("SHA256SUMS"):
    h, fn = ln.split()
    d = hashlib.sha256(open(fn, "rb").read()).hexdigest()
    if d != h:
        print("SHA MISMATCH", fn); bad += 1
rows = 0
for p in ("p1", "p2", "p3", "p4"):
    for ln in open(f"rows/{p}.jsonl"):
        r = json.loads(ln); rows += 1
        if len(r["cites"]) < 2:
            print("UNGROUNDED", r["eq_hash"]); bad += 1
        if r["load_bearing"] and not (r.get("wire_back") and os.path.isfile(r["wire_back"])):
            print("UNWIRED (wire_back missing or not shipped)", r["eq_hash"]); bad += 1
        if not (r["refuted"]["attempted"] and r["refuted"]["survived"]):
            print("UNREFUTED", r["eq_hash"]); bad += 1
        if r["provenance"]["frontier_touched_raw"]:
            print("DIRTY-HANDS", r["eq_hash"]); bad += 1
adm = [json.loads(l) for l in open("rows/admission.jsonl") if l.strip()]
if any(a["verdict"] != "ADMIT" for a in adm) or len(adm) < rows:
    print("ADMISSION INCOMPLETE"); bad += 1
print(f"REPRO {'PASS' if not bad else 'FAIL'}: rows={rows} admitted={len(adm)} defects={bad}")
sys.exit(1 if bad else 0)
PY
# the shipped guard must prove its own teeth, then go GREEN on this tree
sh guards/corpus-admission.sh --selftest
sh guards/corpus-admission.sh .
echo "ANCHOR: none-local — SHA256SUMS proves internal consistency only; verify against the published release timestamp"
