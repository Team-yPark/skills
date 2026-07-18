---
title: Repeated-measures / non-independent designs need mixed models, not plain ANOVA
area: statistics
tags: [repeated-measures, mixed-model, random-effects, anova, independence, blocking]
confidence: established
updated: 2026-07-18
sources:
  - Laird & Ware 1982 (Biometrics 38:963) — random-effects models
  - Pinheiro & Bates 2000, Mixed-Effects Models in S and S-PLUS
---

## Fact
When observations are **not independent** — repeated measures on the same subject,
samples nested in animals/plates/batches, longitudinal timepoints — a plain
between-groups ANOVA is invalid. The classical fix is **repeated-measures ANOVA**;
the general and now-standard fix is a **linear mixed model (LMM)** that adds
**random effects** for the grouping (e.g. `y ~ treatment + (1 | subject)`),
separating within-subject from between-subject variation.

## Why it matters
Ignoring the correlation structure and treating repeated/nested samples as
independent is pseudoreplication ([[pseudoreplication]]): it fabricates degrees of
freedom and inflates significance. Mixed models use every observation while
correctly attributing the shared variance, which is both valid and more powerful
than collapsing to per-subject means when group sizes are unequal.

## Caveats
Repeated-measures ANOVA assumes **sphericity** (equal variances of the differences);
violation inflates false positives — apply a Greenhouse–Geisser correction, or use
an LMM, which handles unbalanced/missing data that classic RM-ANOVA cannot. Random
vs fixed effect is a modeling decision (is the level a sample from a population, or
of intrinsic interest?). Denominator degrees of freedom in LMMs are approximate
(Satterthwaite/Kenward-Roger).

## See also
[[pseudoreplication]] · [[factorial-anova-interaction]] · [[one-way-anova]]
