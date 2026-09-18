# backprop-corpus

A knowledge row that cites text not in the source is a hallucination with a footnote; this
corpus admits a row only when every claim's cited spans are verbatim in crawled chunks.

- Deterministic: same input, same verdict, exit code contract.
- Offline: no network, no dependencies, POSIX sh + bash only, nothing to install.
- Self-proving: `bash REPRO.sh` re-derives every admission and checks SHA256SUMS; the guard's
  `--selftest` must catch a planted rejected row and a planted dead wire-back (two negative controls).

## Quickstart

```bash
git clone https://github.com/mpuodziukas-labs/backprop-corpus
cd backprop-corpus
bash guards/corpus-admission.sh --selftest
bash REPRO.sh
```

Expected last line: `REPRO PASS: 12/12 rows admitted, 0 defects`

| exit code | meaning |
|---|---|
| 0 | every row re-admits and the manifest matches |
| 1 | a defect or checksum mismatch (named on stdout) |
| 2 | usage error |

It does not judge whether a claim is true; it does not do semantic or cross-chunk entailment.
Grounding here is verbatim span containment in a crawled chunk, so a correct paraphrase is a
false negative and is rejected.

Each governance framework named here is tied to one artifact in this tree, nothing more: model risk management under an SR 11-7 style validation approach maps to independent re-derivation (`REPRO.sh`); the EU AI Act transparency duty maps to the per-row `provenance` field (`schema.json`); ISO 42001 AI management system requirements map to the documented failure classes (`FAILURES.md`); the NIST AI RMF measure and manage functions map to the exit-code contract and the guard selftest. This repo is one control receipt, not a certification, and no auditor has signed it.

Run it on your own corpus and open an issue with the REPRO output if a row re-admits that should not.

## What a row is

Each row (`schema.json`) carries: `eq_hash` (sha256[:16] of the normalized claim), `pillar`,
`claim` (an atomic statement), `cites` (>=2 sha16 hashes of crawled source chunks), `load_bearing`,
`wire_back` (a guard path or null), `refuted` (whether an adversarial pass tried and failed to
break the claim), and `provenance` (whether a frontier model ever touched the raw source). A
claim is "grounded" only when every one of its cited spans is a verbatim substring of the chunk
it cites. `abstain` semantics: a candidate row with fewer than 2 verbatim cites is never admitted.

## Limits

This is verbatim span containment, not entailment. Known false-negative modes: a correct
paraphrase of a cited chunk, a claim resolved only through coreference across sentences, and a
claim whose support is split across chunks. There is no semantic check and no truth check --
"refuted-then-survived" means an adversarial pass failed to break the sentence as written, not
that the sentence is true.

## Layout
- `schema.json` -- the sealed row + admission contract
- `rows/p{1..4}.jsonl` -- admitted rows, one pillar per file
- `rows/admission.jsonl` -- one verdict per row (`eq_hash`, `verdict`)
- `guards/corpus-admission.sh` -- the guard every load-bearing row's `wire_back` names; ships here so you can run it
- `SHA256SUMS` -- integrity manifest; `REPRO.sh` verifies it
- `REPRO.sh` -- stdlib-only verifier (no installs, no network)
- `FAILURES.md` -- the failure classes this pipeline hit and what each one wires back to
- `CLAIMS-EVIDENCE.md` -- every number this README states, with its artifact and verifier
- `LICENSE` -- MIT

## Reproduce
```
bash REPRO.sh
```
Exits 0 iff SHA256SUMS verifies, every row re-derives as grounded/wired/refuted/clean-hands with
a matching `eq_hash` and no duplicate, and the shipped guard passes its own selftest on this tree.

## Evidence
See [CLAIMS-EVIDENCE.md](CLAIMS-EVIDENCE.md) for every number and its verifier, and
[FAILURES.md](FAILURES.md) for the failure classes each check exists because of.

## Case study
Companion gate and case study: https://github.com/mpuodziukas-labs/rag-grounded-gate and https://puodziukas.dev

## Timestamp
After each release the SHA256SUMS.ots OpenTimestamps proof is attached as a release asset;
verify with `ots verify`. Until that release lands, treat this artifact as internally
consistent only (see `REPRO.sh`'s `ANCHOR: none-local` line).

## License
MIT -- see [LICENSE](LICENSE).
