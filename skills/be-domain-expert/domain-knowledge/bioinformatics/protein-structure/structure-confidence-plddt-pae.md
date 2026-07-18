---
title: Read predicted structures through pLDDT and PAE
area: bioinformatics
tags: [alphafold, plddt, pae, confidence, ptm, iptm, disorder]
confidence: established
updated: 2026-07-18
sources:
  - Jumper et al. 2021 (Nature 596:583); Tunyasuvunakool et al. 2021 (AlphaFold DB) — https://alphafold.ebi.ac.uk
  - EBI AlphaFold training — pLDDT/PAE interpretation
---

## Fact
A predicted structure is only usable with its confidence scores:

- **pLDDT** — per-residue confidence, 0–100 (per-**atom** in AF3):
  - **>90** high — backbone *and* side chains reliable (e.g. binding-site work).
  - **70–90** good backbone, some side-chain error.
  - **50–70** low — treat with caution.
  - **<50** very low — often **intrinsically disordered**, not a real fold.
- **PAE** (Predicted Aligned Error) — expected position error of residue *x* when
  aligned on residue *y*; a residue×residue map. **Low inter-domain/inter-chain PAE
  = confident relative orientation**; high PAE there means the domains/partners'
  relative arrangement is uncertain, even if each is individually well-folded.
- **pTM / ipTM** — global single number for the fold / for an interface in a
  complex (ipTM > ~0.8 suggests a reliable interface).

## Why it matters
pLDDT tells you *whether each part is folded correctly*; PAE tells you *whether the
parts are placed correctly relative to each other* — a different question. A
multi-domain model can be all-high-pLDDT yet have high inter-domain PAE, meaning the
domain packing shown is not trustworthy. Judging a complex or domain arrangement by
pLDDT alone is a common, serious mistake.

## Caveats
These are the model's **self-estimates**, not ground truth — usually well-
calibrated but not infallible, and confidently-wrong cases exist (e.g. repeat
proteins). Low pLDDT means "no confident single structure," which for a disordered
region is the correct answer, not an error. Colour a structure by pLDDT and inspect
the PAE plot before interpreting.

## See also
[[alphafold2-msa-structure-prediction]] · [[predicted-structure-caveats]] · [[protein-domains-modular-units]]
