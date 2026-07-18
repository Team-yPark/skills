---
title: ANCOVA — ANOVA adjusted for a continuous covariate
area: statistics
tags: [ancova, covariate, adjustment, confounder, linear-model, design]
confidence: established
updated: 2026-07-18
sources:
  - Fisher 1932; Cochran 1957 (Biometrics 13:261) — analysis of covariance
---

## Fact
ANCOVA extends ANOVA by adding one or more **continuous covariates** to the model,
testing group differences in the outcome **after adjusting for** those covariates:

```
y ~ group + covariate        (test the group effect holding the covariate fixed)
```

It removes covariate-driven variance from the residual, sharpening the group test,
and corrects group comparisons for a covariate that differs across groups. ANOVA,
ANCOVA, and regression are all the same **general linear model** with different
predictor types (categorical, mixed, continuous).

## Why it matters
Biological outcomes often carry a continuous nuisance — age, body size, RNA
integrity (RIN), sequencing depth, a batch proxy. Adjusting for it as a covariate
(1) prevents a confound from masquerading as a group effect and (2) increases power
by shrinking unexplained variance. It is the model-based alternative to removing a
covariate's effect beforehand.

## Caveats
Classic ANCOVA assumes **homogeneity of regression slopes** — the covariate relates
to the outcome the same way in every group (no group×covariate interaction); if
slopes differ, fit and interpret that interaction instead. The covariate should be
measured without large error and **not itself affected by the grouping** (adjusting
for a mediator removes the effect you want). Do not adjust for a covariate
perfectly confounded with group ([[batch-correction-by-data-type]]).

## See also
[[factorial-anova-interaction]] · [[one-way-anova]] · [[batch-correction-by-data-type]]
