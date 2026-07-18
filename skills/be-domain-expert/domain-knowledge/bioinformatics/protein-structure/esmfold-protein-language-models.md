---
title: ESMFold — single-sequence structure from a protein language model
area: bioinformatics
tags: [esmfold, esm, protein-language-model, single-sequence, embeddings, speed]
confidence: established
updated: 2026-07-18
sources:
  - Lin et al. 2023, ESMFold / ESM-2 (Science 379:1123) — https://github.com/facebookresearch/esm
---

## Fact
ESMFold predicts structure **without an MSA**. A large **protein language model**
(ESM-2), pretrained self-supervised on hundreds of millions of sequences by masked
prediction, has internalized evolutionary/structural regularities in its per-residue
embeddings; a folding head maps those embeddings straight to 3D coordinates. Because
it skips the MSA search, it is roughly an **order of magnitude faster** than AF2 and
runs from a single sequence.

Accuracy is slightly below AF2 on well-conserved proteins (e.g. median TM ~0.95 vs
~0.96) but it holds up better on proteins with **few homologs** — orphan, fast-
evolving, designed, or metagenomic sequences — where the MSA is shallow.

## Why it matters
It changes the throughput/coverage trade-off: ESMFold enabled folding entire
metagenomic catalogues (the ESM Metagenomic Atlas, ~600M structures) that MSA-based
methods could not afford. Use it when you have many sequences, need speed, or the
protein has no usable alignment; use AF2/AF3 when you have a deep MSA and need the
last increment of accuracy. ESM embeddings are also reusable features for
function/property prediction, independent of folding.

## Caveats
The accuracy gap is real and largest exactly where language models are most
tempting (shallow-MSA proteins) — check pLDDT, don't assume. No MSA also means no
coevolution cross-check. Single-chain, single static conformation, same as AF2
([[predicted-structure-caveats]]).

## See also
[[alphafold2-msa-structure-prediction]] · [[msa-coevolution-structure-signal]] · [[transformer-masked-pretraining]]
