---
title: Protein domains are the modular units of fold and function
area: biochemistry
tags: [protein, domain, fold, evolution, multi-domain, modularity]
confidence: established
updated: 2026-07-18
sources:
  - Lehninger Principles of Biochemistry; SCOP / Pfam domain classifications
---

## Fact
A **domain** is a compact, semi-independently folding part of a protein — often
100–250 residues — that is a structural, functional, and evolutionary unit. Many
proteins are **multi-domain**: domains fold on their own and are shuffled and
reused across proteins over evolution (e.g. kinase, SH3, immunoglobulin domains).
Databases catalogue them by sequence (Pfam) and structure (SCOP/CATH).

## Why it matters
Domains, not whole proteins, are the natural unit of analysis: function is usually
localized to a domain, and structure prediction is typically confident **within**
each domain but far less certain about **how domains are arranged relative to each
other** — exactly what PAE reports ([[structure-confidence-plddt-pae]]). Splitting
a large protein into domains before predicting or interpreting is standard.

## Caveats
Domain boundaries can be fuzzy and are sometimes contested. Inter-domain linkers
are often flexible/disordered, so a single predicted arrangement may be one of
many. Some domains only fold in the context of a partner or the full chain, so
predicting an isolated domain can mislead.

## See also
[[protein-structure-levels]] · [[structure-confidence-plddt-pae]]
