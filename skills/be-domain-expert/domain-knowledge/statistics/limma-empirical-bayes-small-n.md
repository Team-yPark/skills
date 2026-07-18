---
title: Empirical-Bayes variance shrinkage rescues power at small replicate n
area: statistics
tags: [limma, empirical-bayes, moderated-t, variance, rna-seq, small-n]
confidence: established
updated: 2026-07-18
sources:
  - Smyth 2004, limma empirical Bayes (Stat Appl Genet Mol Biol 3:3)
---

## Fact
With few replicates (n = 2–4, typical for omics), a **per-gene** variance
estimate is extremely noisy, so an ordinary t-test has ~n−1 degrees of freedom
and little power. limma's **moderated t-test** borrows information across all
genes: it estimates a genome-wide prior from the distribution of per-gene
variances, then replaces each gene's variance with a **posterior** value shrunk
toward that prior. This raises the effective degrees of freedom from ~4 (Welch,
n=3) to >20, sharpening every gene's test.

## Why it matters
It is why limma (and empirical-Bayes shrinkage generally — also DESeq2/apeGLM for
fold-changes) outperforms per-gene t-tests on small-n high-dimensional data. The
many-genes-few-samples shape is a feature, not a problem: the gene dimension
supplies the information the replicate dimension lacks.

## Caveats
Assumes most genes share a common variance structure (exchangeable prior); wildly
heteroscedastic data weakens the gain. limma expects normalized, log/variance-
stabilized input, not raw counts ([[count-models-need-raw-counts]]). Shrinkage
trades a little bias for a large variance reduction — usually worth it, but it is
a modeling assumption, not free.

## See also
[[count-models-need-raw-counts]] · [[deseq2-median-of-ratios]]
