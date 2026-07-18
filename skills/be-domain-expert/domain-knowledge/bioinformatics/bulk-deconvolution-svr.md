---
title: Cell-type deconvolution of bulk omics via support-vector regression
area: bioinformatics
tags: [deconvolution, cibersort, svr, cell-type, bulk, signature-matrix]
confidence: established
updated: 2026-07-18
sources:
  - Newman et al. 2015, CIBERSORT (Nat Methods 12:453) — https://cibersort.stanford.edu
  - Newman et al. 2019, CIBERSORTx (Nat Biotechnol 37:773) — https://cibersortx.stanford.edu
---

## Fact
A bulk sample is a mixture of cell types. **Deconvolution** estimates each cell
type's proportion by expressing the bulk profile as a non-negative combination of
reference cell-type **signature** columns. The CIBERSORT approach solves this with
**ν-support-vector regression (SVR)**: the support-vector formulation is robust to
noise and to signature genes that don't fit, and it implicitly selects the
informative genes. Reference signatures typically come from single-cell/single-
nucleus atlases; the fitted coefficients are normalized to sum to 1.

## Why it matters
Bulk expression changes can reflect **shifts in cell-type composition** rather than
per-cell regulation — an apparent "downregulation" may just be fewer of a cell
type. Deconvolution separates the two and recovers a composition time-course from
cheap bulk data without sorting or single-cell sequencing.

## Caveats
Results are only as good as the reference: signatures must match the tissue,
platform, and species, and cross-platform use (scRNA reference → bulk protein)
needs the shared gene space aligned and is approximate. It gives **relative**
proportions, not absolute counts. Rare or transcriptionally similar cell types are
poorly resolved. Validate against a known ground-truth mixture where possible.

## See also
[[gene-id-mapping-multitier]] · [[wgcna-coexpression-modules]]
