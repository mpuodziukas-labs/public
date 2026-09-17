# Backprop Corpus — admission-gated knowledge rows

12 rows across four sealed pillars, each admitted by a single offline oracle with four
preconditions: **grounded** (>=2 source-chunk citations), **wired** (load-bearing rows map to a
guard with a self-test), **refuted-then-survived** (an adversarial lane tried to break it), and
**clean-hands** (no frontier model read raw source HTML).

| pillar | scope | rows |
|---|---|---|
| p1 | math & gradient integrity | 2 |
| p2 | systems & hardware | 7 |
| p3 | optimization topology | 1 |
| p4 | gotchas & anomalies | 2 |

## Layout
- `schema.json` — the sealed row + admission contract
- `rows/p{1..4}.jsonl` — admitted rows
- `rows/admission.jsonl` — one verdict per row (`eq_hash`, `verdict`)
- `guards/corpus-admission.sh` — the guard every load-bearing row's `wire_back` names; ships here so you can run it
- `SHA256SUMS` — integrity of every file above (a local tamper + re-hash is NOT caught: the external anchor is the signed release, not this file)
- `REPRO.sh` — stdlib-only verifier (no installs, no network)

## What this is / is not
This is a few dozen knowledge rows about backpropagation, mechanically extracted verbatim from
14 public ML documents, each carrying >=2 source-chunk citations and a machine verdict from an
offline admission oracle. It is not peer review and not a benchmark: the adversarial pass is a
single local model, and the counts here are claims about *process*, not about truth. Verify it
yourself with `sh REPRO.sh` — and verify the checksums against the published timestamp, because
until then this artifact only proves it is internally consistent with itself.

Rows are verbatim sentences from public ML documentation, admitted by an offline oracle; the
adversarial lane is a local model, so "refuted-then-survived" means *it failed to break the
sentence as written*, not that the sentence is a complete or context-free statement. A claim's
`cites` are hashes of the crawled source chunks; the corpus is provenance, not authority.

## Reproduce
```
sh REPRO.sh
```
Exits 0 iff every checksum matches, every row has >=2 citations, every load-bearing row names a
wire-back, and no admission verdict is REJECT. Zero dependencies beyond a POSIX shell and python3.
