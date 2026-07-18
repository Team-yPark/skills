# organism-reference-setup — Reference

Loaded only when `SKILL.md` points here. Source URL patterns, the NCBI Datasets
package layout, derived-artifact recipes, and sizing.

## Source URL patterns

Verify a URL by listing its directory before committing to a download — FTP
layouts and release numbering change.

### Ensembl (vertebrates)

```bash
REL=112                       # pin it; record it in MANIFEST.tsv
SP=homo_sapiens; SPU=Homo_sapiens; ASM=GRCh38
BASE=https://ftp.ensembl.org/pub/release-${REL}

# genome (primary_assembly, soft-masked)
${BASE}/fasta/${SP}/dna/${SPU}.${ASM}.dna_sm.primary_assembly.fa.gz
# annotation
${BASE}/gtf/${SP}/${SPU}.${ASM}.${REL}.gtf.gz
# checksums (per directory)
${BASE}/fasta/${SP}/dna/CHECKSUMS
${BASE}/gtf/${SP}/CHECKSUMS
```

Ensembl `CHECKSUMS` uses BSD `sum` (`sum -r`), **not** md5 — verify with
`sum -r file` and compare, or fall back to size. Do not assume md5 here.

Current release, if the user truly wants latest (then pin what you resolved):

```bash
REL=$(curl -s 'https://rest.ensembl.org/info/software?content-type=application/json' \
      | grep -o '"release":[0-9]*' | cut -d: -f2)
```

### Ensembl Genomes / WormBase ParaSite (invertebrates, plants, fungi)

Separate tree and **separate release numbering** from main Ensembl:

```bash
https://ftp.ensemblgenomes.ebi.ac.uk/pub/metazoa/release-${EGREL}/fasta/...
https://ftp.ebi.ac.uk/pub/databases/wormbase/parasite/releases/WBPS${N}/species/...
```

WormBase ParaSite filenames carry a BioProject
(`caenorhabditis_elegans.PRJNA13758.WBPS19.*`) — the BioProject is part of the
identity, not noise. Different BioProjects are different assemblies.

### GENCODE (human, mouse)

```bash
https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_46/GRCh38.primary_assembly.genome.fa.gz
https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_46/gencode.v46.annotation.gtf.gz
```

UCSC-style seqnames (`chr1`). Transcript FASTA headers are `|`-separated, which
breaks parsers expecting whitespace. Biotype attribute is `gene_type` where
Ensembl uses `gene_biotype` — anything filtering on biotype needs adjusting.

### UCSC

```bash
https://hgdownload.soe.ucsc.edu/goldenPath/${DB}/bigZips/${DB}.fa.gz
https://hgdownload.soe.ucsc.edu/goldenPath/${DB}/bigZips/md5sum.txt
```

`${DB}` is the UCSC build key (`hg38`, `mm39`, `ce11`) — **not** the Ensembl
assembly name. Genomes are easy here; a matching GTF is fiddlier (Table Browser
or `genePredToGtf`), which is why mixing a UCSC FASTA with an Ensembl GTF is such
a common and destructive mistake.

## NCBI Datasets

The preferred route for NCBI, and often the best option for organisms absent from
Ensembl/UCSC. The `datasets` CLI composes the download for you instead of hand-
building FTP paths.

### Accessions

`GCF_` = RefSeq (curated), `GCA_` = GenBank (submitter-provided). Prefer `GCF_`
when it exists. The version suffix is part of the identity — `GCF_000001405.40`
and `.39` are different assemblies.

### Commands

```bash
# by accession
datasets download genome accession GCF_000001405.40 --include genome,gtf

# by taxon, reference assembly only
datasets download genome taxon "Caenorhabditis elegans" --reference --include genome,gtf

# custom output name (default: ncbi_dataset.zip)
datasets download genome accession GCF_000001405.40 --include genome,gtf --filename ce.zip
```

### `--include` values

Default is `genome` alone — a bare `datasets download genome` gets **no
annotation**, which is a common surprise.

| Value | Retrieves |
|---|---|
| `genome` | genomic sequence (default) |
| `rna` | transcript sequences |
| `protein` | amino acid sequences |
| `cds` | nucleotide coding sequences |
| `gff3` | general feature format |
| `gtf` | gene transfer format |
| `gbff` | GenBank flat file |
| `seq-report` | sequence report |
| `all` | everything above |
| `none` | metadata only, no sequence files |

For a preprocessing pipeline, `--include genome,gtf` is normally what you want.

### Useful flags

| Flag | Purpose |
|---|---|
| `--assembly-source` | restrict to `RefSeq` (GCF_) or `GenBank` (GCA_) |
| `--assembly-level` | `chromosome`, `complete`, `contig`, `scaffold` |
| `--reference` | reference genomes only — the usual choice for a taxon query |
| `--annotated` | only assemblies that have annotation |
| `--released-after` | ISO 8601 `YYYY-MM-DD` |
| `--dehydrated` | data report + file locations only; rehydrate later |
| `--filename` | output zip name |

`--dehydrated` is useful for large multi-assembly queries: fetch the catalogue,
decide, then `datasets rehydrate` only what you need.

### Package layout

The download is a zip. Unzipped:

```
ncbi_dataset.zip
├── README.md
├── md5sum.txt
└── ncbi_dataset/
    └── data/
        ├── assembly_data_report.jsonl      # assembly metadata
        ├── dataset_catalog.json            # catalogue of every file in the package
        └── <assembly_accession>/
            ├── <accession>_<name>_genomic.fna   # genome FASTA
            ├── genomic.gtf
            ├── genomic.gff
            ├── genomic.gbff
            ├── rna.fna
            ├── protein.faa
            ├── cds_from_genomic.fna
            └── sequence_report.jsonl
```

Three things follow from this layout:

**The genomic FASTA name is not fixed.** It interpolates the accession and
assembly name (`GCF_000001405.40_GRCh38.p14_genomic.fna`), while the annotation
files have stable names (`genomic.gtf`). Glob it rather than hardcoding:

```bash
fna=$(find ncbi_dataset/data/<accession> -name '*_genomic.fna' | head -1)
```

Better, read `dataset_catalog.json` — it lists every file with its type, so you
do not have to guess names at all.

**Files are uncompressed inside the zip.** No `gunzip` step, unlike Ensembl.

**`md5sum.txt` is at the archive root** and covers the package contents:

```bash
unzip -q ncbi_dataset.zip -d ncbi_out && (cd ncbi_out && md5sum -c md5sum.txt)
```

Run this before using anything. It is the one verification step NCBI hands you
for free.

### Normalising into the layout

The package layout is not the `data/<organism>/` layout, so copy the two files
you need to stable names and record provenance:

```bash
acc=GCF_000001405.40
src="ncbi_out/ncbi_dataset/data/${acc}"
cp "$(find "${src}" -name '*_genomic.fna' | head -1)" "${ORG_DIR}/genome.fa"
cp "${src}/genomic.gtf"                                "${ORG_DIR}/genes.gtf"
printf '%s\t%s\t%s\t%s\n' "genome.fa" "NCBI:${acc}" \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(md5sum "${ORG_DIR}/genome.fa" | awk '{print $1}')" \
    >> "${MANIFEST}"
```

RefSeq seqnames are accessions (`NC_000001.11`) — unambiguous, but they match
neither Ensembl (`1`) nor UCSC (`chr1`). Since the FASTA and GTF come from one
package they agree with each other, which is what matters; just do not mix them
with references from elsewhere. `sequence_report.jsonl` carries the mapping
between accessions and chromosome names if you need to translate.

### Other package types

`gene` (sequences/metadata for genes), `virus` (GenBank virus genomes, SARS-CoV-2
proteins), and `taxonomy` (taxonomic metadata) packages exist with the same
`ncbi_dataset/data/` + `dataset_catalog.json` shape. Not needed for genome
reference setup.

## Assembly name equivalences

Same coordinates, different names — a frequent source of confusion:

| Ensembl | UCSC | NCBI (human ex.) | Organism |
|---|---|---|---|
| GRCh38 | hg38 | GCF_000001405.40 | human |
| GRCh37 | hg19 | GCF_000001405.25 | human |
| GRCm39 | mm39 | GCF_000001635.27 | mouse |
| WBcel235 | ce11 | GCF_000002985.6 | C. elegans |

Equivalent coordinates do **not** mean interchangeable files: seqnames differ
(`1` vs `chr1` vs `NC_…`), and so does mitochondrial naming (`MT` vs `chrM`).

## Seqname conversion (last resort)

Prefer taking both files from one source. If you must convert:

```bash
# Ensembl → UCSC style, GTF
awk 'BEGIN{OFS="\t"} /^#/{print; next} {if ($1=="MT") $1="chrM"; else $1="chr"$1; print}' \
    in.gtf > out.gtf
```

Fragile — scaffold and patch names do not follow the rule, and a partial
conversion is worse than none: concordance then passes on the main chromosomes
while scaffolds silently drop. Re-run the concordance check afterwards and
compare *counts*, not just "shared > 0".

For NCBI accession-style names, use the `sequence_report.jsonl` mapping rather
than a regex.

## Canonical transcript (one per gene)

| Organism | Source | Extraction |
|---|---|---|
| Human | MANE Select GTF (NCBI) | use directly |
| Any Ensembl organism (release ≥104) | Ensembl GTF | `grep 'tag "Ensembl_canonical"' in.gtf > canonical.gtf` |
| Any organism | full GTF + AGAT | `agat_sp_keep_longest_isoform.pl -gff in.gtf -o out.gtf` |
| Any organism | custom script | longest CDS per gene, longest exon span for non-coding |

Prefer a curated source. The AGAT/longest-CDS route is structural, not curated:
it picks the longest isoform, which is not always the biologically dominant one.

Why it matters for footprint assays: short reads on exons shared between isoforms
cannot identify their isoform of origin, so a one-transcript-per-gene backbone
removes ambiguity the data cannot resolve. Keep the full GTF too —
transcriptome-coordinate BAMs are keyed to it.

## Transcript 5' extension

Some analyses (TSS coverage, start-codon metagene) need transcripts extended
upstream. Do it at GTF level before index building, since `--sjdbGTFfile` bakes
the model into the index:

```bash
"${PYTHON}" extend_tx_upstream.py --gtf in.gtf --out out.ext.gtf --extension 100
```

An extended GTF produces a **different index**. Name the index directory after
the GTF that built it (`index/star_ext100`) or you will silently align against
the wrong model. Never let two GTF variants share one index path.

## rRNA / contaminant reference

Not usually shipped with a genome. Options, in rough order of preference:

1. **Extract from the GTF by biotype** — no extra download, matches the assembly:
   ```bash
   awk '$0!~/^#/ && /gene_biotype "rRNA"/' genes.gtf > rrna.gtf
   bedtools getfasta -fi genome.fa -bed rrna.gtf -fo rrna.fa
   ```
   (GENCODE: `gene_type`. NCBI GTF: check the attribute names, they differ.)
2. **SILVA** — comprehensive. Releases ≤119 require licensing for commercial use;
   138+ is CC-BY 4.0.
3. **Rfam / NCBI** — fetch rRNA records for the organism.

Coverage matters more than elegance: a partial rRNA reference means a low
apparent contaminant rate and rRNA leaking into the alignment. Sanity-check the
rate against expectation (footprint libraries commonly show high rRNA), and
document what went in — the number is meaningless without it.

Add tRNA and other abundant ncRNA only if the protocol calls for it; keep
rRNA-only and combined indexes as separate files so the choice stays an option.

## Sizing

| Artifact | Disk | Peak RAM to build |
|---|---|---|
| Human genome FASTA (gz → raw) | ~1 GB → ~3 GB | — |
| Human STAR index | ~30 GB | **~38 GB** |
| Compact genome (~100 Mb) STAR index | ~2–4 GB | ~4–8 GB |
| bowtie2 rRNA index | a few MB | small |
| CDS/transcript STAR index | ~1–2 GB | small, but `--genomeSAindexNbases` must shrink |

STAR `genomeGenerate` for a mammalian genome runs tens of minutes to hours on
many cores. Under-provisioned memory shows up as an OOM kill, which on a shared
node looks like an unexplained silent failure — check `dmesg` before assuming the
data is at fault.

Reuse indexes across projects: build once, store centrally, point `config.sh` at
the shared path.
