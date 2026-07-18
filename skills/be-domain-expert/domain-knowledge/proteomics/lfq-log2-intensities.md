---
title: LFQ intensities are analyzed on the log2 scale
area: proteomics
tags: [proteomics, lfq, quantification, log2, maxquant, dia, dda]
confidence: established
updated: 2026-07-18
sources:
  - Cox et al. 2014, MaxLFQ (Mol Cell Proteomics 13:2513)
  - Ritchie et al. 2015, limma (Nucleic Acids Res 43:e47)
---

## Fact
Label-free quantification (LFQ) reports a per-protein **intensity** (e.g. MaxQuant
MaxLFQ, DIA-NN). Raw intensities span many orders of magnitude and are
right-skewed, so proteomics analysis works on **log2(intensity)**, on which
protein abundances are approximately normal and fold-changes are additive
(difference of log2 = log2 ratio). Missing values are structured, not random
([[mnar-imputation]]).

## Why it matters
Nearly every downstream method assumes the log scale: limma / t-test differential
expression, PCA, clustering, and batch correction (ComBat) all expect
approximately-Gaussian, homoscedastic input, which log2 LFQ provides and raw
intensity does not. Reporting a "fold change" means a difference of log2 means.

## Caveats
LFQ is **relative**, not absolute copy number — comparable across samples for the
same protein, not across proteins. DDA (data-dependent) has more missingness and
run-to-run variability than DIA (data-independent). Normalize (median/quantile)
before cross-sample comparison, since total loaded protein varies. Very
low-intensity proteins near the noise floor are unreliable even after log.

## See also
[[mnar-imputation]] · [[differential-protein-expression]] · [[count-models-need-raw-counts]]
