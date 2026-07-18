---
title: Translation efficiency (TE) and three-layer regulation classes
area: bioinformatics
tags: [ribo-seq, rna-seq, translation-efficiency, deltate, anota2seq, integration]
confidence: established
updated: 2026-07-18
sources:
  - Chothani et al. 2019, deltaTE (Curr Protoc Mol Biol; DESeq2 interaction model)
  - anota2seq (Oertlin et al. 2019); riboWaltz/Ribo-seq TE convention
---

## Fact
**Translation efficiency (TE)** is ribosome load per unit mRNA — how hard a
transcript is being translated, separate from how abundant it is. With matched
Ribo-seq (RPF) and RNA-seq on the same samples, per gene per sample:

```
TE = log2(RPF_norm + 1) − log2(mRNA_norm + 1)
```

Both matrices are size-factor normalized first (e.g. DESeq2 median-of-ratios).
Differential TE across conditions is a **statistical interaction** (RPF change
relative to mRNA change), fit either as a DESeq2 `~condition + assay +
condition:assay` model (deltaTE) or `log2(RPF) ~ log2(mRNA) + condition`
(anota2seq). Genes are then classed by which layer moved:

| Class | mRNA | RPF | TE |
|---|---|---|---|
| Transcriptional / Forwarded | change | changes with it | ~unchanged |
| Translational | ~flat | changes | changes |
| Buffered | change | opposed/flat | changes |
| Intensified | change | amplified | changes |

## Why it matters
TE separates transcriptional from translational control — a gene can hold steady
mRNA while its ribosome occupancy rises (translational upregulation), invisible
to RNA-seq alone. Adding proteomics extends this to a three-layer
mRNA→RPF→protein classification.

## Caveats
TE is a ratio, so it is sensitive to normalization and to low counts — filter
genes with negligible RPF. Read-length mismatch between assays biases the ratio
via mappability (see nf-core read-length-equalisation). It quantifies ribosome
occupancy, a proxy for synthesis, not protein output directly.

## See also
[[count-models-need-raw-counts]] · [[three-nt-periodicity]]
