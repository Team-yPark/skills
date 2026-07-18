---
title: Negative-binomial count models require raw counts, not TPM/CPM
area: statistics
tags: [deseq2, edger, rna-seq, normalization, count-model, tpm]
confidence: established
updated: 2026-07-18
sources:
  - Love et al. 2014, DESeq2 (Genome Biology 15:550)
  - Anders & Huber 2010; DESeq2/edgeR documentation
---

## Fact
DESeq2 and edgeR model gene counts with a **negative binomial** distribution and
estimate library-size (size factors) and gene-wise dispersion **internally** from
raw integer counts. They must be fed **raw counts**, never TPM, CPM, RPKM, or any
pre-normalized/transformed matrix. Pre-normalizing violates the count-model
assumptions, double-applies library-size correction, and destroys the
mean–variance relationship the dispersion estimator depends on.

## Why it matters
It is a frequent, silent misuse: pipe TPM into DESeq2 and it still "runs" and
emits p-values — that are wrong. Any tool documented as an NB/count model
(differential expression, per-frame Ribo-seq counts, ORF counts) takes the raw
count matrix; normalization is the model's job.

## Caveats
The opposite holds for methods that assume normal, homoscedastic input —
limma-voom, PCA, clustering, correlation — which want a normalized, log/variance-
stabilized matrix (TPM, VST, rlog). Match the input to the model. Gene-length
normalization (TPM) is also pointless for same-gene cross-condition comparisons:
length cancels out.

## See also
[[deseq2-median-of-ratios]] · [[limma-empirical-bayes-small-n]]
