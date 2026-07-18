---
title: WGCNA — co-expression modules, eigengenes, and hub genes
area: bioinformatics
tags: [wgcna, co-expression, network, module-eigengene, hub-genes, soft-threshold]
confidence: established
updated: 2026-07-18
sources:
  - Zhang & Horvath 2005 (Stat Appl Genet Mol Biol 4:17) — soft-threshold / scale-free
  - Langfelder & Horvath 2008, WGCNA (BMC Bioinformatics 9:559)
---

## Fact
WGCNA turns a feature × sample matrix into co-expression **modules**:

1. **Adjacency** — correlate every gene pair, then raise |corr| to a soft
   **power β** (`pickSoftThreshold`) chosen so the network is approximately
   **scale-free** (a few hubs, many low-degree nodes). Soft-thresholding keeps
   the network weighted instead of hard-cutting edges.
2. **Topological overlap (TOM)** — reweight by shared neighbours; cluster the
   `1 − TOM` distance hierarchically and cut the tree into modules.
3. **Module eigengene (ME)** — the **first principal component** of a module's
   expression, a single per-sample summary of the whole module.
4. **Hub genes** — highest **intramodular connectivity** (or top ME correlation).
5. **Module–trait association** — correlate MEs with phenotypes to find the
   modules that track a condition.

## Why it matters
It collapses thousands of correlated genes into a handful of interpretable modules
summarized by their eigengenes, so downstream tests (module–trait correlation,
differential eigengenes across genotypes) run on ~10 variables instead of
thousands — far fewer multiple-testing penalties and a systems-level readout.

## Caveats
The correlation step has **no NaN handling** (`np.corrcoef` / WGCNA statics assume
complete data) — impute or filter missing values first. β selection is a judgement
call (target scale-free R² ≳ 0.8); too low gives noise-dominated modules, too high
collapses everything. Modules are correlation structure, **not causation**. Cross-
dataset module preservation needs an explicit test (Z-summary), not a re-run.

## See also
[[mnar-imputation]] · [[principal-component-regression-clock]] · [[molecular-noise-increases-with-age]]
