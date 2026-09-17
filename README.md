# Backprop Corpus — admission-gated knowledge rows

30 rows across four sealed pillars, each admitted by a single offline oracle with four
preconditions: **grounded** (>=2 source-chunk citations), **wired** (load-bearing rows map to a
guard with a self-test), **refuted-then-survived** (an adversarial lane tried to break it), and
**clean-hands** (no frontier model read raw source HTML).

| pillar | scope | rows |
|---|---|---|
| p1 | math & gradient integrity | 7 |
| p2 | systems & hardware | 10 |
| p3 | optimization topology | 4 |
| p4 | gotchas & anomalies | 9 |

## Layout
- `schema.json` — the sealed row + admission contract
- `rows/p{1..4}.jsonl` — admitted rows
- `rows/admission.jsonl` — one verdict per row (`eq_hash`, `verdict`)
- `SHA256SUMS` — integrity of every file above
- `REPRO.sh` — stdlib-only verifier (no installs, no network)

## Reproduce
```
sh REPRO.sh
```
Exits 0 iff every checksum matches, every row has >=2 citations, every load-bearing row names a
wire-back, and no admission verdict is REJECT. Zero dependencies beyond a POSIX shell and python3.
