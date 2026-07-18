---
title: Shotgun metagenomics — assembly and binning into MAGs
area: bioinformatics
tags: [metagenomics, shotgun, assembly, binning, mag, taxonomic-profiling]
confidence: established
updated: 2026-07-18
sources:
  - nf-core/mag (Krakau et al. 2022, NAR Genom Bioinform 4:lqac007) — https://github.com/nf-core/mag
  - MEGAHIT (Li et al. 2015) — https://github.com/voutcn/megahit; MetaBAT2 (Kang et al. 2019) — https://bitbucket.org/berkeleylab/metabat
---

## Fact
Shotgun metagenomics sequences **all DNA** in a sample (not one marker gene), so
it profiles both *who is there* and *what they can do*. Two complementary
analyses (nf-core/mag does both):

1. **Read-based taxonomic/functional profiling** — classify reads directly
   (Kraken2/Bracken, MetaPhlAn) for composition and gene/pathway content.
2. **Assembly + binning** — QC and **remove host reads** → assemble contigs
   (MEGAHIT / metaSPAdes) → **bin** contigs into **MAGs** (metagenome-assembled
   genomes, e.g. MetaBAT2) → assess with CheckM (completeness/contamination) →
   taxonomically classify (GTDB-Tk).

## Why it matters
Unlike 16S amplicon, shotgun gives strain/species resolution and **functional
potential** (genes, pathways, antibiotic-resistance), and assembly can recover
near-complete genomes of uncultured organisms. Choose shotgun over amplicon when
function or genome recovery matters and you can afford the depth.

## Caveats
Far more expensive and compute-heavy than amplicon; host-read removal is essential
for host-associated samples or most reads are wasted. Assembly of complex
communities is fragmentary; low-abundance members don't bin well. A MAG is a
statistical reconstruction, not a cultured isolate — always report CheckM
completeness/contamination. Functional *potential* (genes present) is not
expression.

## See also
[[amplicon-16s-metagenomics]] · [[nf-core-standardized-pipelines]]
