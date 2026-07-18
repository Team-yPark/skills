---
title: Single-cell RNA-seq quantification — barcodes, UMIs, empty droplets
area: bioinformatics
tags: [scrna-seq, single-cell, umi, cell-barcode, empty-droplets, 10x, alevin]
confidence: established
updated: 2026-07-18
sources:
  - nf-core/scrnaseq pipeline (https://github.com/nf-core/scrnaseq); Heumos et al. 2023, sc-best-practices (Nat Rev Genet 24:550)
  - Lun et al. 2019, emptyDrops (Genome Biology 20:63) — DropletUtils https://bioconductor.org/packages/DropletUtils
---

## Fact
Droplet single-cell RNA-seq (10x, Drop-seq) tags each transcript with two
barcodes: a **cell barcode** (which droplet/cell) and a **UMI** (which original
molecule). Raw processing has four stages: **map** reads
([[scrna-mapping-reference-choice]]) → **correct cell barcodes**
([[scrna-barcode-correction]]) → **resolve UMIs** ([[scrna-umi-resolution]]) →
**quantify** into a **cell × gene** count matrix. This entry is the overview; the
linked entries cover each stage.

A critical step is **empty-droplet detection**: most droplets contain only ambient
RNA, not a cell. A **knee-plot** cutoff on total counts is the crude method;
**emptyDrops** tests each barcode's profile against the ambient distribution and
recovers small real cells that a knee cutoff discards.

## Why it matters
UMI collapsing removes PCR amplification bias, so counts reflect molecules, not
reads — essential because scRNA amplification is enormous. Getting empty-droplet
calling wrong either floods the matrix with ambient "cells" (knee too low) or
discards real small cells (knee too high); emptyDrops is the principled fix.

## Caveats
The output is sparse, over-dispersed counts needing scRNA-specific downstream
(normalization, doublet removal, clustering) — not bulk methods. Ambient RNA
contamination persists after filtering (needs SoupX/DecontX). Counts are raw
integers for the count model ([[count-models-need-raw-counts]]). Different
aligners give systematically different matrices; pin one.

## See also
[[scrna-mapping-reference-choice]] · [[scrna-barcode-correction]] · [[scrna-umi-resolution]] · [[bulk-deconvolution-svr]] · [[count-models-need-raw-counts]] · [[nf-core-standardized-pipelines]]
