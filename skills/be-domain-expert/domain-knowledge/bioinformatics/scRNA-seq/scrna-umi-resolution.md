---
title: scRNA-seq UMI resolution — collapse duplicates, but not naively
area: bioinformatics
tags: [scrna-seq, umi, deduplication, multimapping, em, umi-tools, alevin]
confidence: established
updated: 2026-07-18
sources:
  - Heumos et al. 2023, sc-best-practices (Nat Rev Genet 24:550) — https://www.sc-best-practices.org/introduction/raw_data_processing.html
  - Smith et al. 2017, UMI-tools (Genome Res 27:491) — https://github.com/CGATOxford/UMI-tools; Srivastava et al. 2019 (alevin-fry https://github.com/COMBINE-lab/alevin-fry)
---

## Fact
A **UMI** tags each molecule before PCR, so reads sharing (cell, gene, UMI) are
amplification copies of one molecule and must be collapsed to a count of 1. Two
complications make "count distinct UMIs" wrong:

1. **UMI sequencing errors** create near-duplicate UMIs that inflate the molecule
   count. Fix: collapse UMIs within an edit distance (θ=1) using a **directional
   graph** method (UMI-tools) rather than exact-match.
2. **Multi-gene UMIs** — a UMI whose reads map to several genes — are ambiguous.
   Discarding them biases against gene families with homology; **EM/probabilistic
   assignment** (alevin-fry, STARsolo option) instead allocates them using
   gene-unique UMIs as evidence.

## Why it matters
Naive unique-UMI counting simultaneously **overcounts** (each UMI error becomes a
"molecule") and **mishandles multimappers**, and the resolution method materially
changes the counts — most for homologous genes and for intronic reads used in RNA
velocity. This is the difference between reproducible and inflated expression.

## Caveats
θ=1 is a convention, not settled — it can over- or under-collapse. Collisions are
real: *convergent* (two molecules, same UMI — rare) and *divergent* (one molecule,
multiple UMIs — common in unspliced/intronic regions, still an open problem).
Methods disagree, so counts are **tool-dependent** — pin the pipeline. Feed raw
integer counts downstream ([[count-models-need-raw-counts]]).

## See also
[[single-cell-rnaseq-quantification]] · [[scrna-barcode-correction]] · [[scrna-mapping-reference-choice]] · [[count-models-need-raw-counts]]
