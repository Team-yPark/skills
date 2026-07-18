---
title: P-site offset — definition and typical values
area: bioinformatics
tags: [ribo-seq, p-site, offset, codon-resolution]
confidence: established
updated: 2026-07-18
sources:
  - Lauria et al. 2018, riboWaltz (PMC6112680) — https://github.com/LabTranslationalArchitectomics/riboWaltz
  - Ingolia et al. 2009 (PMID 19213877); Weinberg et al. 2016
---

## Fact
The **P-site offset** is the distance, in nucleotides, from the **5′ end of an
RPF read** to the first nucleotide of the codon in the ribosomal P-site. It is
what converts a mapped read into a codon-resolution position. Offsets are
assigned **per read length**. Representative values (5′-end offsets):

| Read length | P-site offset |
|---|---|
| 27–28 nt | 11–13 |
| 29–30 nt | 12–14 |
| 31 nt | 12–13 |

riboWaltz on mouse: 28→11, 29–30→12, 31→13. Classic yeast (Ingolia/Weinberg):
~12–14, a touch larger. A flat **12 nt for all lengths** is a common fallback
(e.g. Ribo-TISH default).

## Why it matters
Codon-level positioning — periodicity, pause scores, frame assignment, A/P-site
analysis — is only as accurate as the offset. A wrong offset shifts every read
by a fixed amount and can collapse the periodicity signal. Offsets differ by
organism, ribosome, and nuclease/drug conditions, so they should be calibrated
per dataset rather than copied (see calibration entry).

## Caveats
5′-end vs 3′-end and A-site vs P-site conventions differ between tools; A-site =
P-site + 3 nt. 0-based/1-based indexing bugs shift stored offsets by 1 nt — a
uniform shift leaves differential results intact but breaks absolute position
calls. Shorter RPFs from MNase / genome-aligned data run 1–2 nt shorter than
CHX-treated yeast values.

## See also
[[three-nt-periodicity]] · [[psite-offset-calibration]]
