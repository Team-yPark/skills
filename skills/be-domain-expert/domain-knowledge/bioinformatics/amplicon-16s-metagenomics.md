---
title: Amplicon (16S) microbiome analysis — ASVs, not OTUs
area: bioinformatics
tags: [amplicon, 16s, microbiome, dada2, asv, otu, taxonomy, ampliseq]
confidence: established
updated: 2026-07-18
sources:
  - nf-core/ampliseq (Straub et al. 2020, Front Microbiol 11:550420) — https://github.com/nf-core/ampliseq
  - Callahan et al. 2016, DADA2 (Nat Methods 13:581) — https://github.com/benjjneb/dada2
  - QIIME 2 — https://qiime2.org
---

## Fact
Amplicon sequencing profiles a community by sequencing one marker gene (bacterial
**16S rRNA**, fungal ITS). Standard workflow (ampliseq): **trim primers**
(Cutadapt — mandatory, primers are not biological sequence) → **DADA2** infers
**amplicon sequence variants (ASVs)** → assign taxonomy against a reference
(SILVA for 16S) → filter → **alpha/beta diversity** → differential abundance
(ANCOM).

**ASVs supersede OTUs.** Legacy OTUs cluster reads at a fixed similarity (e.g.
97%), merging distinct taxa and being uncomparable across studies. DADA2 models
sequencing error to resolve exact sequences to single-nucleotide resolution, so
ASVs are reproducible and directly comparable between datasets.

## Why it matters
Failing to remove primers corrupts ASV inference and taxonomy. ASV vs OTU is a
real, consequential choice — ASVs are the current standard and give a consistent
feature definition across experiments. Diversity comparisons across groups use
PERMANOVA on a distance matrix ([[permanova-distance-based]]).

## Caveats
16S resolves to genus, rarely reliable species — do not over-interpret species
calls. Copy-number variation of 16S biases abundances. It captures **composition,
not function** (use shotgun/`mag` for gene content). Primer choice (V3–V4 etc.)
and the reference database strongly shape results — report both. Compositional
data need appropriate stats (relative abundances are not independent).

## See also
[[shotgun-metagenomics-mag]] · [[permanova-distance-based]] · [[nf-core-standardized-pipelines]]
