# FAILURES

A failure class is a named way this pipeline broke while the corpus was built. Every class below became a deterministic check, either inside the shipped guard (`guards/corpus-admission.sh`) or inside `REPRO.sh`, so reproducing this artifact re-triggers every one of these checks.

| # | class | wire-back |
|---|---|---|
| F1 | local-extractor-degenerate | n/a |
| F2 | verdict-parser-closed-vocabulary | n/a |
| F7 | downstream-restates-unverified-fact (council dominant class) | n/a |
| F8 | non-verbatim-provenance | n/a |
| F9 | dead-guard-in-public-artifact | guards/corpus-admission.sh |
| F10 | non-atomic-writes | n/a |
| F11 | non-atomic-claims | n/a |
| F12 | typed-tallies-drift | n/a |
| F13 | near-duplicate-inflation | n/a |
| F15 | verdict-label-rescued-by-explanation | n/a |
| F14 | no-external-anchor | n/a |
| F16 | gate-runs-a-different-oracle-than-the-button | n/a |
| F17 | generator-owns-the-publish-tells | n/a |
| F18 | debug-marker-collision-in-placeholder-token | n/a |
| F3 | affirmed-but-false-claim | n/a |
| F4 | sealed-criterion-wrong-tool-contract | n/a |
| F5 | sealed-criterion-chunks-dir-polluted | n/a |
| F6 | frontier-handle-not-dispatchable | n/a |
