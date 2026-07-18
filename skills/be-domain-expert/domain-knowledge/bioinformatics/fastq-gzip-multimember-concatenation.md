---
title: Concatenating gzipped FASTQs with cat is valid
area: bioinformatics
tags: [fastq, gzip, lane-merging, file-formats]
confidence: established
updated: 2026-07-18
sources:
  - RFC 1952 (GZIP file format) — https://www.rfc-editor.org/rfc/rfc1952 (a gzip file is a series of members)
  - verified empirically, BCbB lane-concatenation test, 2026-07
---

## Fact
gzip is a **multi-member** format: a valid gzip stream may be several compressed
members concatenated. Therefore `cat a.fastq.gz b.fastq.gz > merged.fastq.gz`
produces a valid gzip file whose decompressed content is the concatenation of the
inputs. Standard readers (`zcat`, `zgrep`, fastp, `STAR --readFilesCommand
gunzip -c`, samtools) all handle multi-member gzip transparently.

## Why it matters
Merging sequencing lanes of one sample needs no decompress/recompress cycle —
`cat` is correct, fast, and lossless. Decompressing to merge and re-gzipping
wastes time and I/O for no benefit.

## Caveats
- The result is not re-blocked, so it is slightly larger than re-compressing the
  combined data as one member; this is negligible and does not affect
  correctness.
- This is specific to gzip/BGZF-style member concatenation. It does **not**
  generalise to formats with a single header+index (e.g. you cannot `cat` two
  BAMs — use `samtools cat`/`merge`; two `.zip` archives; or two indexed files).
- Order is preserved, so for paired-end keep R1 and R2 lane order identical
  across the two `cat` calls.

## See also
[[reference-seqname-conventions]]
