---
title: DESeq2 median-of-ratios size-factor normalization
area: statistics
tags: [deseq2, normalization, size-factors, rna-seq, ribo-seq]
confidence: established
updated: 2026-07-18
sources:
  - Anders & Huber 2010 (Genome Biology 11:R106)
  - Love et al. 2014, DESeq2 (Genome Biology 15:550)
---

## Fact
DESeq2's **median-of-ratios** method estimates a per-sample size factor to make
libraries comparable, robust to a few highly-expressed genes dominating the
total:

1. Per gene, take the geometric mean of its counts across all samples → a
   pseudo-reference.
2. Per sample, take the ratio of each gene's count to that reference.
3. The sample's **size factor is the median** of those ratios (genes with a zero
   in any sample are excluded from the geometric mean).

Divide counts by the size factor to normalize. It assumes most genes are not
differentially expressed, so the median ratio reflects sequencing depth, not
biology.

## Why it matters
It is the default normalization behind DESeq2 differential expression and is used
directly to normalize RPF and mRNA matrices before computing translation
efficiency, so that a TE ratio reflects biology rather than differing library
depths. More robust than total-count/CPM scaling, which a handful of very high
genes can skew.

## Caveats
The "most genes unchanged" assumption breaks under global shifts (e.g. massive
transcriptional amplification, or samples with little overlap in expressed
genes); spike-ins or alternative normalization are needed then. Size factors are
computed on **raw counts** ([[count-models-need-raw-counts]]).

## See also
[[count-models-need-raw-counts]] · [[limma-empirical-bayes-small-n]] · [[translation-efficiency]]
