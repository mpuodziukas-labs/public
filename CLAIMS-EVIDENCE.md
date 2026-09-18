# CLAIMS-EVIDENCE

Every number below is computed by the generator or re-derived by REPRO.sh; none is typed.

| claim | number | artifact | verifier |
|---|---|---|---|
| admitted rows | 12 | rows/p1.jsonl rows/p2.jsonl rows/p3.jsonl rows/p4.jsonl + rows/admission.jsonl | REPRO.sh |
| sealed pillars | 4 | schema.json | REPRO.sh |
| minimum citations per admitted row | 2 | rows/p1.jsonl rows/p2.jsonl rows/p3.jsonl rows/p4.jsonl | REPRO.sh |
| planted failures caught by the guard selftest | 2 | guards/corpus-admission.sh | guards/corpus-admission.sh --selftest |
| files covered by the manifest | 12 | SHA256SUMS | shasum -a 256 -c SHA256SUMS |
