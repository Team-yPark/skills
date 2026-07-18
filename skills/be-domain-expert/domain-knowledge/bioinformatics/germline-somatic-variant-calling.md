---
title: Germline vs somatic variant calling (GATK best-practices / sarek)
area: bioinformatics
tags: [variant-calling, gatk, mutect2, bqsr, somatic, germline, sarek, vcf]
confidence: established
updated: 2026-07-18
sources:
  - nf-core/sarek (Garcia et al. 2020, F1000Research 9:63) — https://github.com/nf-core/sarek
  - GATK Best Practices (DePristo et al. 2011); Mutect2 (Benjamin et al. 2019) — https://github.com/broadinstitute/gatk
---

## Fact
DNA variant calling detects SNVs/indels vs a reference. Standard workflow
(GATK best-practices, as in sarek):

1. **Preprocess** — align (BWA-MEM) → mark duplicates → **base quality score
   recalibration (BQSR)** → QC.
2. **Call** — **germline** with HaplotypeCaller (per-sample GVCF → joint
   genotyping); **somatic** with **Mutect2** on a **tumour/normal pair**, which
   subtracts the patient's germline variants to leave tumour-acquired mutations.
3. **Filter → normalize → annotate** — PASS-filter, `bcftools norm`, optional
   multi-caller consensus, then functional annotation (VEP / snpEff).

## Why it matters
Germline (inherited, ~heterozygous/homozygous, present in every cell) and somatic
(acquired, often low variant-allele-fraction, tumour-only) are fundamentally
different problems: a germline caller applied to a tumour floods you with inherited
variants, and a somatic caller needs the matched normal to distinguish acquired
mutations from private germline ones. Choose the caller by the question.

## Caveats
Reference build and its contig naming must match across BAM, known-sites, and
annotation ([[reference-seqname-conventions]]). Somatic calling at low VAF is
sensitivity-limited and needs a panel-of-normals to suppress recurrent artefacts.
BQSR needs a known-variants resource, which is scarce for non-model organisms.
Annotation is only as current as the transcript database version.

## See also
[[nf-core-standardized-pipelines]] · [[reference-seqname-conventions]] · [[bisulfite-methylation-sequencing]]
