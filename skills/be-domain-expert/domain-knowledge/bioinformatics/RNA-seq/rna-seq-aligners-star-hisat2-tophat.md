---
title: Splice-aware RNA-seq aligners — STAR, HISAT2, and (deprecated) TopHat
area: bioinformatics
tags: [rna-seq, alignment, star, hisat2, tophat, splice-aware, aligner]
confidence: established
updated: 2026-07-18
sources:
  - Dobin et al. 2013, STAR (Bioinformatics 29:15) — https://github.com/alexdobin/STAR; Kim et al. 2019, HISAT2 (Nat Biotechnol 37:907) — https://github.com/DaehwanKimLab/hisat2
  - Kim et al. 2013, TopHat2 (Genome Biology 14:R36) — now deprecated (https://github.com/DaehwanKimLab/tophat)
---

## Fact
RNA-seq reads cross exon–exon junctions, so genome alignment needs a **splice-aware**
aligner that can map a read across an intron:

| Aligner | Index / method | Trait |
|---|---|---|
| **STAR** | uncompressed suffix array | fastest; **memory-heavy** (~30 GB for human) |
| **HISAT2** | hierarchical graph FM-index | low memory (~few GB); fast; good default when RAM-limited |
| **TopHat / TopHat2** | Bowtie(2) + junction search | **deprecated** — do not use for new work |

TopHat2's own authors deprecated it and recommend **HISAT2** as its successor; STAR
is the other mainstream choice. All emit sorted BAM
([[sam-bam-cram-alignment-formats]]).

## Why it matters
Using a non-splice-aware DNA aligner (BWA, Bowtie) on RNA-seq soft-clips or drops
junction-spanning reads, undercounting spliced genes. Among the splice-aware three,
the live choice is STAR (speed, if you have RAM) vs HISAT2 (memory efficiency);
seeing **TopHat** in a pipeline is a sign it is outdated. Aligning to the genome
(vs a transcriptome quantifier) is what you want when you need the BAM itself —
coverage, novel junctions, variant calling.

## Caveats
`--alignIntronMax` etc. must suit the organism's intron sizes
([[star-genomesaindexnbases-small-genome]] covers the related index knob). Aligner
choice changes counts slightly — pin one across a study. If you only need
transcript/gene abundance (not a BAM), an alignment-free quantifier is faster and
lighter ([[salmon-kallisto-transcript-quantification]]).

## See also
[[salmon-kallisto-transcript-quantification]] · [[sam-bam-cram-alignment-formats]] · [[star-genomesaindexnbases-small-genome]] · [[nf-core-standardized-pipelines]]
