#!/bin/sh
# REPRO.sh - verify this artifact with nothing but sh + python3. No installs, no network.
set -eu
cd "$(dirname "$0")"
python3 - <<'PY'
import hashlib, json, os, re, subprocess, sys

def sha_check():
    tool = None
    for candidate in ("shasum", "sha256sum"):
        probe = subprocess.run(["sh", "-c", "command -v " + candidate],
                                capture_output=True)
        if probe.returncode == 0:
            tool = candidate
            break
    if tool is None:
        print("REPRO FAIL: 0/0 no sha256 tool available")
        sys.exit(1)
    args = ["shasum", "-a", "256", "-c", "SHA256SUMS"] if tool == "shasum" \
        else ["sha256sum", "-c", "SHA256SUMS"]
    r = subprocess.run(args, capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stdout + r.stderr)
        print("REPRO FAIL: 0/0 SHA256SUMS mismatch")
        sys.exit(1)

sha_check()

bad = 0
candidates = 0
admitted = 0
seen = set()
for p in ("p1", "p2", "p3", "p4"):
    for ln in open("rows/%s.jsonl" % p):
        if not ln.strip():
            continue
        r = json.loads(ln)
        candidates += 1
        ok = True
        if len(r.get("cites", [])) < 2:
            print("UNGROUNDED", r.get("eq_hash")); ok = False
        wb = r.get("wire_back")
        if r.get("load_bearing") and not wb:
            print("UNWIRED", r.get("eq_hash")); ok = False
        if wb and not os.path.isfile(wb):
            print("DEAD-WIRE-BACK", r.get("eq_hash")); ok = False
        ref = r.get("refuted") or {}
        if not (ref.get("attempted") and ref.get("survived")):
            print("UNREFUTED", r.get("eq_hash")); ok = False
        if (r.get("provenance") or {}).get("frontier_touched_raw"):
            print("DIRTY-HANDS", r.get("eq_hash")); ok = False
        recomputed = hashlib.sha256(re.sub(r"\s+", " ", r.get("claim", "").lower()).encode()).hexdigest()[:16]
        if recomputed != r.get("eq_hash"):
            print("EQ-HASH-MISMATCH", r.get("eq_hash")); ok = False
        if r.get("eq_hash") in seen:
            print("DUPLICATE-EQ-HASH", r.get("eq_hash")); ok = False
        else:
            seen.add(r.get("eq_hash"))
        if ok:
            admitted += 1
        else:
            bad += 1

adm = [json.loads(l) for l in open("rows/admission.jsonl") if l.strip()]
if any(a.get("verdict") != "ADMIT" for a in adm) or len(adm) < candidates:
    print("ADMISSION-INCOMPLETE")
    bad += 1

if bad:
    print("REPRO FAIL: %d/%d rows admitted, %d defects" % (admitted, candidates, bad))
    sys.exit(1)

sel = subprocess.run(["sh", "guards/corpus-admission.sh", "--selftest"], capture_output=True, text=True)
if sel.returncode != 0:
    print(sel.stdout + sel.stderr)
    print("REPRO FAIL: %d/%d rows admitted, guard selftest failed" % (admitted, candidates))
    sys.exit(1)

chk = subprocess.run(["sh", "guards/corpus-admission.sh", "."], capture_output=True, text=True)
if chk.returncode != 0:
    print(chk.stdout + chk.stderr)
    print("REPRO FAIL: %d/%d rows admitted, guard check failed on this tree" % (admitted, candidates))
    sys.exit(1)

print("REPRO PASS: %d/%d rows admitted, %d defects" % (admitted, candidates, bad))
print("ANCHOR: none-local. SHA256SUMS proves internal consistency only; the release timestamp is the external anchor.")
sys.exit(0)
PY
