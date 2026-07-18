---
title: nf-core provides community-standard, reproducible analysis pipelines
area: bioinformatics
tags: [nf-core, nextflow, pipelines, reproducibility, containers, best-practice]
confidence: established
updated: 2026-07-18
sources:
  - Ewels et al. 2020 (Nat Biotechnol 38:276) — the nf-core framework
  - nf-co.re pipeline catalogue — https://nf-co.re (repos: https://github.com/nf-core)
---

## Fact
**nf-core** is a curated collection of Nextflow analysis pipelines that encode
community-consensus best practice for common assays. Each pipeline is versioned,
peer-reviewed, containerized (Docker/Singularity/Conda) with pinned tool versions,
CI-tested, and documented to a shared template — so "the nf-core pipeline for
assay X" is a reasonable proxy for "the standard analysis workflow for X".
Widely-used ones beyond RNA-seq / Ribo-seq:

| Pipeline | Assay |
|---|---|
| `sarek` | germline/somatic variant calling (WGS/WES) |
| `chipseq` / `atacseq` | TF-histone binding / chromatin accessibility |
| `methylseq` | bisulfite DNA methylation |
| `scrnaseq` | single-cell RNA-seq |
| `ampliseq` / `mag` | amplicon (16S) / shotgun metagenomics |

## Why it matters
Reaching for the relevant nf-core pipeline gives a validated, reproducible default
instead of a hand-assembled workflow that silently omits QC or best-practice
steps. The pipeline's step list is a good template for what a correct analysis of
that assay includes, even when you implement it yourself.

## Caveats
Pipelines evolve — tool choices and defaults change between releases, so **pin the
version** and read that version's docs, not a general memory. Standard defaults
are tuned for common (often human/mouse) cases and may need adjustment for unusual
organisms or protocols. "nf-core has a pipeline" is a catalogue fact that dates;
the durable knowledge is the *workflow* each encodes.

## See also
[[chip-seq-analysis]] · [[germline-somatic-variant-calling]] · [[single-cell-rnaseq-quantification]] · [[amplicon-16s-metagenomics]]
