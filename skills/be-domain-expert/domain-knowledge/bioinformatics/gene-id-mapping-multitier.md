---
title: Cross-annotation gene-ID mapping needs a multi-tier fallback
area: bioinformatics
tags: [gene-id, mapping, orthology, ensembl, ncbi, biomart, annotation]
confidence: established
updated: 2026-07-18
sources:
  - Ensembl BioMart; NCBI gene2ensembl
  - verified empirically, killifish Ensembl↔NCBI mapping (~52% recovered), 2026-07
---

## Fact
Joining two datasets annotated against different sources (e.g. Ensembl gene IDs vs
NCBI symbols/`LOC` IDs, or different assembly releases) by **direct string match
fails for a large fraction of genes** — often roughly half. No single identifier
maps completely, so use a **layered fallback**, each tier catching what the prior
missed:

1. Direct match on a normalized key (lowercased symbol / shared ID).
2. Cross-reference table (Ensembl BioMart `external_gene_name`).
3. Authority mapping (NCBI `gene2ensembl`: Ensembl ID → NCBI GeneID → symbol).

Then drop unmapped genes and collapse many-to-one mappings.

## Why it matters
Downstream analysis silently operates on whatever genes survived the join — a poor
mapping quietly discards half the data and can bias results toward well-annotated
genes. A tiered map recovers most of them and makes the coverage explicit and
auditable (record how many mapped at each tier).

## Caveats
Mapping is many-to-many: one symbol can hit several IDs and vice versa; decide a
dedup rule (drop ambiguous, or sum counts). Symbols drift between releases and are
not stable keys — prefer stable IDs where possible. The recoverable fraction is
species- and release-dependent; the ~50% figure is illustrative, not a constant.
Orthology across species is a harder problem than ID mapping within one species —
use dedicated ortholog databases, not symbol matching.

## See also
[[reference-seqname-conventions]]
