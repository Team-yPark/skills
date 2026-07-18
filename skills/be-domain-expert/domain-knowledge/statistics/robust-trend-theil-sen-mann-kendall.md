---
title: Robust trend estimation — Theil–Sen slope and Mann–Kendall test
area: statistics
tags: [robust-statistics, trend, theil-sen, mann-kendall, non-parametric, outliers]
confidence: established
updated: 2026-07-18
sources:
  - Sen 1968 (J Am Stat Assoc 63:1379) — Theil–Sen estimator
  - Mann 1945; Kendall 1975 — Mann–Kendall trend test
---

## Fact
When a trend is fit from few, noisy points (common in time-course omics), pair OLS
with non-parametric companions:

- **Theil–Sen slope** — the **median of the slopes** of all point pairs. It has a
  ~29% breakdown point, so a single wild bin barely moves it, unlike least squares.
- **Mann–Kendall test** — tests **monotone** trend (does y tend to rise with x?)
  from the sign of all pairwise differences, assuming no particular functional
  form and no normality. Reports `tau` (rank correlation) and a p-value.

Report OLS slope for the effect size, Theil–Sen as the robust slope, and
Mann–Kendall as the assumption-light significance check; agreement across the three
is the signal to trust.

## Why it matters
OLS is efficient but fragile: with n≈5–15 an outlier or a heavy tail can flip the
sign or significance of a slope. The robust pair tells you whether an OLS trend is
real structure or one leverage point — cheap insurance for small-n trajectories.

## Caveats
Theil–Sen/Mann–Kendall detect **monotone** trends; they miss non-monotone
(U-shaped) ones — pair with a visual check. Both still assume **independent**
points, so aggregate first if the data are grouped ([[pseudoreplication]]).
Mann–Kendall needs handling for ties and, for time series, autocorrelation.

## See also
[[pseudoreplication]] · [[limma-empirical-bayes-small-n]]
