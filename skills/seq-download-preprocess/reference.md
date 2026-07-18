# seq-download-preprocess — Reference

Loaded only when `SKILL.md` points here. Parameter tables and flag rationale.

## Adapter sequences

| Library kit / family | 3' adapter |
|---|---|
| Illumina TruSeq generic | `AGATCGGAAGAGC` |
| NEBNext / TruSeq small RNA | `TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC` |
| Illumina small RNA (older) | `TCGTATGCCGTCTTCTGCTTG` |
| Common Ribo-seq linker | `CTGTAGGCACCATCAAT` |
| Unknown | `auto` — fastp autodetects |

`auto` is safe for standard RNA-seq. For Ribo-seq prefer an explicit sequence:
footprints are short enough that autodetection can misfire, and a wrong adapter
shows up as a collapsed length distribution, not an error. Always confirm the
adapter against the library kit's documentation or the paper's methods — never
carry one over from another dataset.

## Per-assay presets

| Parameter | Ribo-seq | RNA-seq |
|---|---|---|
| `--length_required` (min) | 22 | 20 |
| `--length_limit` (max) | 36 | **omit** |
| `--trim_front1` | 1 (small-RNA ligation kits) | 0 |
| `--outFilterMultimapNmax` | 1 | 10 (or default) |
| `--outFilterMismatchNmax` | 2 | default |
| `--alignEndsType` | `EndToEnd` | default (soft-clip OK) |
| rRNA depletion | required | recommended |

Two of these are silent-failure traps when copied across assays:

**`--length_limit 36` on RNA-seq** discards nearly every read — RNA-seq inserts
are 50–150 nt. The run "succeeds" with near-zero output. Omit the flag entirely.

**`--trim_front1 1`** removes the non-templated nucleotide added by RNA ligase in
small-RNA library prep (equivalent to `fastx_trimmer -f 2`). Correct for Ribo-seq
protocols using such kits; destructive for standard RNA-seq, where it silently
shortens every read by one base. Confirm against the library prep before setting.

**`auto` does nothing on paired-end without `--detect_adapter_for_pe`.** fastp
autodetects adapters for single-end by default but **not** for paired-end. Pass
`--detect_adapter_for_pe` for PE autodetection, or an explicit
`--adapter_sequence`. Without either, "auto" silently trims nothing — the run
succeeds, the adapter stays in the reads, and the alignment rate quietly drops.

**Read-length windows.** Ribosome-protected fragments are typically ~26–34 nt
(monosome footprints often quoted as 28–32). A wider trim window (e.g. 22–36)
paired with a downstream periodicity filter that selects which lengths to keep is
a legitimate strategy — the trim window need not be the final length selection.
Decide which of the two is doing the work, and document it.

## `--alignIntronMax`

| Genome type | Value | Rationale |
|---|---|---|
| Compact genomes (nematode, insect, fungal) | ~25000 | introns are short; the default bridges genes |
| Mammalian / large genomes | `1000000` | STAR default |
| Alignment to a CDS/transcript FASTA | `1` | no introns exist in the reference |

STAR's default on a compact genome lets reads span unrelated genes. There is no
error — just wrong alignments. Derive the value from the organism's intron length
distribution rather than copying it between projects.

## STAR

**Strictness flags for footprint data** (the equivalent of a Bowtie v1 `-m 1 -v 2`
global alignment):

| Flag | Purpose |
|---|---|
| `--outFilterMultimapNmax 1` | unique mappers only |
| `--outSAMmultNmax 1` | at most one record per read |
| `--outFilterMismatchNmax 2` | ≤ 2 mismatches |
| `--alignEndsType EndToEnd` | no soft-clipping |
| `--alignIntronMax 1` | no spliced alignment (CDS/transcript reference) |

Soft-clipping must stay off for footprint data: a clipped end shifts the inferred
P-site and corrupts periodicity downstream.

**Ribo-seq-tuned alternatives** seen in dedicated tooling — more permissive on
multimapping, stricter on mismatch:
`--outFilterMismatchNmax 1 --outFilterMismatchNoverLmax 0.04 --outFilterType BySJout --winAnchorMultimapNmax 100 --seedSearchStartLmaxOverLread 0.5`.
Different choices here change periodicity and score distributions, so a run is
only comparable to another run using the same flags. Record them.

**`--quantMode GeneCounts` costs nothing and answers strandedness.** STAR emits
`<prefix>ReadsPerGene.out.tab` during the alignment it is already doing:

```
column 2 = counts for unstranded protocol
column 3 = counts for forward-stranded (htseq-count -s yes)
column 4 = counts for reverse-stranded (htseq-count -s reverse)
```

Compare the column totals to determine the library's strandedness empirically —
a strongly asymmetric col3/col4 means stranded (whichever is larger), roughly
equal means unstranded. A preprocessing script cannot infer strandedness, but it
can hand the user the evidence instead of a guess. The first four rows are
`N_unmapped`, `N_multimapping`, `N_noFeature`, `N_ambiguous`; genes follow.

**Memory:** STAR needs roughly 38 GB for a human-sized genome index. Budget
accordingly; it is a common cause of silent job kills on shared nodes.

**`ulimit -n 65536`** before STAR — it opens a file per contig and dies with "too
many open files" on many-contig assemblies.

**`--genomeSAindexNbases` must shrink for small references** (a transcript or CDS
library is not a genome):

```bash
total_len=$(awk '/^>/{next}{t+=length($0)}END{print t}' "${REF_FASTA}")
sa_idx=$(python3 -c "import math; print(min(14, int(math.log2(${total_len})/2 - 1)))")
```

Leaving it at the default of 14 on a small reference makes STAR allocate absurd
memory or fail outright.

**`--sjdbOverhang` is baked into the index** at `genomeGenerate` time and cannot
be changed at alignment time — changing it requires rebuilding. It is also
read-length dependent, so an index built for short footprints is wrong for long
RNA-seq reads and vice versa. One shared index across both assays is a
compromise, not a free choice.

## bowtie2 contaminant filter

```
-x <index>        contaminant index
-U <reads>        single-end input
--no-unal         don't write unaligned reads to SAM
--un-gz <out>     ← the reads we KEEP (non-contaminant), gzipped
-S /dev/null      discard the SAM of aligned (contaminant) reads
-f                add only when input is FASTA, not FASTQ
2> <stats>        bowtie2 writes its summary to stderr
```

The logic inverts what people expect: reads that **fail** to align are the
output. Parse the rate with:

```bash
grep "overall alignment rate" "${stats}" | awk '{print $1}'   # = % contaminant
```

**rRNA-only vs rRNA+tRNA.** rRNA-only is the common published choice for
footprint data. tRNA reads are short and map mostly outside CDS, so they drop out
at the alignment step anyway. Keep both indexes available and make it an option
rather than a hardcoded decision. Alternative rRNA-removal tools are compared in
`nf-core.md`.

## Aligning to a CDS / transcript library

An alternative to whole-genome alignment for footprint data: build the reference
from one transcript per gene (CDS plus a short upstream flank, commonly ~21 nt
before the start codon), then align with `--alignIntronMax 1`.

Rationale: it removes paralog multi-mapping and spurious intronic reads. Short
footprints cannot resolve which isoform they came from when reads fall on shared
exons, so a one-transcript-per-gene reference removes ambiguity the data cannot
resolve anyway (see `nf-core.md` on the canonical backbone).

The upstream flank exists so reads whose P-site sits at the start codon still
have their 5' end on the reference. Match the flank to the offset you expect.

Trade-off: genome mode keeps intronic and intergenic signal (needed for novel ORF
discovery, UTR analysis, contamination diagnosis); CDS mode discards it. Choose
per analysis, and keep the two modes' output filenames distinct so results cannot
be silently mixed.

## SRA / GEO

- A GEO series (`GSE…`) maps to SRA runs (`SRR…`); runs are what `prefetch` takes.
  A GEO sample (`GSM…`) may map to several runs — those are lanes of one sample
  and must be concatenated, not treated as separate samples.
- `prefetch --max-size 10G` — the default cap silently truncates larger runs;
  raise it rather than discover the truncation later.
- `fasterq-dump -t <scratch>` is required; temporaries are multi-GB and the
  default location often is not sized for them.
- `--split-3` yields `<acc>.fastq` (single-end) or `<acc>_1/_2.fastq` (paired).
  The blocks in `SKILL.md` assume single-end; for paired-end, feed both into
  fastp with `--in1/--in2` and carry both through every downstream step.
- fasterq-dump names output after the **accession**, not the sample — rename when
  they differ.
- Concatenating gzipped FASTQs with `cat` is valid (gzip is a multi-member
  format). Do not decompress/recompress to merge lanes.

## Reference genome preparation

Minimum inputs are a genome FASTA and a GTF; everything else (indexes, BED,
transcript FASTA, canonical backbone) is derivable.

- **Ensembl** is the safer default. Avoid pre-packaged iGenomes-style bundles,
  whose annotations are often years out of date — a real problem for anything
  annotation-sensitive.
- **GENCODE** FASTA headers separate transcript IDs with `|` rather than spaces,
  which breaks some parsers. Check before assuming a GTF/FASTA pair is drop-in.
- **GTF filtering:** ensure sequence names match the FASTA and drop rows with
  empty transcript IDs. A silent seqname mismatch (`chr1` vs `1`) produces an
  index that aligns nothing.
- **Spike-ins** (e.g. ERCC) must be concatenated onto both the FASTA and the GTF
  *before* index building.
- **Prokaryotic annotations** are usually GFF with different feature/attribute
  naming than Ensembl GTF; biotype-based QC steps assume the latter and need
  retuning or skipping.
- **Indexing is expensive.** Build once, store centrally, reuse. Gate index
  building on a sentinel file (`${INDEX_DIR}/SA` for STAR, `${IDX}.1.bt2` for
  bowtie2) rather than the directory's existence — a half-built index leaves the
  directory present but unusable.
