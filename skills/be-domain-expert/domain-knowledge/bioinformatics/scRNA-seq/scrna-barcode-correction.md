---
title: scRNA-seq cell-barcode correction against a permit list
area: bioinformatics
tags: [scrna-seq, cell-barcode, error-correction, whitelist, 10x, index-hopping]
confidence: established
updated: 2026-07-18
sources:
  - Heumos et al. 2023, sc-best-practices (Nat Rev Genet 24:550) — https://www.sc-best-practices.org/introduction/raw_data_processing.html
  - 10x Genomics barcode whitelist (3M-february-2018); UMI-tools https://github.com/CGATOxford/UMI-tools
---

## Fact
Each droplet tags its RNA with a **cell barcode (CB)**, but PCR/sequencing errors,
index hopping, and ambient RNA create spurious barcodes. Correction maps observed
barcodes back to true cells by either:

- **Known permit list** — the chemistry's fixed barcode set (e.g. 10x's
  `3M-february-2018`); correct each observed CB to the nearest list entry within a
  small edit distance.
- **Data-derived list** — no fixed list, so pick likely-real barcodes by a
  **knee/elbow** on the ranked UMI-count curve, an expected cell count, or a forced
  cutoff, then correct neighbours to those.

A key limit: **~81% of single-position mutants of the 10x v3 list are equidistant
to more than one barcode**, so many one-error corrections are ambiguous and are
discarded (or broken by base quality).

## Why it matters
Uncorrected barcode errors scatter one cell's reads across phantom barcodes —
inflating the apparent cell count and fragmenting each cell's counts. Correction
depends on **base quality**, not sequence distance alone; treating it as pure
Hamming distance mis-resolves the ambiguous majority.

## Caveats
Not every dataset has a clean knee. A permit list assumes you know the chemistry —
wrong list, wrong correction. Index hopping on patterned flow cells needs separate
handling. This step interacts with empty-droplet calling: both decide "which
barcode is a real cell."

## See also
[[single-cell-rnaseq-quantification]] · [[scrna-umi-resolution]] · [[scrna-mapping-reference-choice]]
