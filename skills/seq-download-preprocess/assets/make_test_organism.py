#!/usr/bin/env python3
"""Generate a tiny synthetic organism + reads for end-to-end pipeline testing.

A real preprocessing run takes hours, so pipelines usually ship verified only as
far as `bash -n`. That leaves the actual logic — the filename chain, paired-end
handling, lane concatenation, filter polarity — untested. This builds a genome
small enough to index in seconds, with reads drawn from its own annotated gene so
they genuinely align, and lets the real script run start to finish in well under
a minute.

It is a smoke test, not a benchmark: it proves the plumbing works, not that any
parameter is biologically right.

Usage:
    python3 make_test_organism.py --outdir data/testorg --fastq-dir testfq

Then, with a data/<organism>/config.sh pointing at it:
    ORGANISM=testorg ./scripts/setup_<organism>_reference.sh -t 8
    ORGANISM=testorg ./scripts/run_<order>_<topic>.sh -m samples.tsv -o /tmp/out

Emits, under --outdir:
    genome.fa                    one chromosome named "1" (Ensembl-style)
    genes.gtf                    GENE1 (protein_coding) + RRNA1 (rRNA biotype)
    config.sh                    ready to source; INTRON_MAX / SA index sized small

and under --fastq-dir:
    pe_L1_1/2.fastq.gz           lane 1 of a paired sample
    pe_L2_1/2.fastq.gz           lane 2 of the SAME sample -> must concatenate
    se.fastq.gz                  single-end sample
    se_rrna.fastq.gz             pure rRNA -> the filter must remove ~all of it

What each fixture proves:
    two PE lanes  -> lane concatenation (an overwriting sample map halves this)
    se + pe       -> layout detection through every step
    se_rrna       -> the contaminant filter keeps NON-aligning reads, not aligning
"""
import argparse
import gzip
import os
import random

GENOME_LEN = 120_000
GENE_START, GENE_END = 10_001, 12_000
RRNA_START, RRNA_END = 50_001, 50_500


def revcomp(s):
    return s.translate(str.maketrans("ACGT", "TGCA"))[::-1]


def write_fastq(path, reads):
    with gzip.open(path, "wt") as f:
        for i, s in enumerate(reads):
            f.write(f"@read{i}\n{s}\n+\n{'I' * len(s)}\n")


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--outdir", default="data/testorg", help="organism directory")
    p.add_argument("--fastq-dir", default="testfq", help="synthetic read directory")
    p.add_argument("--n-pairs", type=int, default=200, help="read pairs per PE lane")
    p.add_argument("--read-len", type=int, default=60)
    p.add_argument("--seed", type=int, default=7, help="fixed for reproducibility")
    a = p.parse_args()

    random.seed(a.seed)
    os.makedirs(f"{a.outdir}/contaminant_ref", exist_ok=True)
    os.makedirs(a.fastq_dir, exist_ok=True)

    genome = "".join(random.choice("ACGT") for _ in range(GENOME_LEN))
    with open(f"{a.outdir}/genome.fa", "w") as f:
        f.write(">1 testchrom\n")
        for i in range(0, len(genome), 60):
            f.write(genome[i:i + 60] + "\n")

    # Sequence name "1" matches the FASTA header: a concordance check must pass.
    rows = []

    def gene(gid, start, end, biotype):
        attr = f'gene_id "{gid}"; transcript_id "{gid}.1"; gene_biotype "{biotype}";'
        rows.append(("1", "test", "gene", start, end, ".", "+", ".",
                     f'gene_id "{gid}"; gene_biotype "{biotype}";'))
        rows.append(("1", "test", "transcript", start, end, ".", "+", ".", attr))
        rows.append(("1", "test", "exon", start, end, ".", "+", ".", attr))

    gene("GENE1", GENE_START, GENE_END, "protein_coding")
    gene("RRNA1", RRNA_START, RRNA_END, "rRNA")   # so rRNA extraction has a target
    with open(f"{a.outdir}/genes.gtf", "w") as f:
        f.write("#!synthetic test organism\n")
        for r in rows:
            f.write("\t".join(str(x) for x in r) + "\n")

    # Reads from GENE1 so they align; PE mates face inward across a ~240nt insert.
    def gene_pairs(n):
        out = []
        for _ in range(n):
            pos = random.randint(GENE_START, GENE_END - 300)
            out.append((genome[pos:pos + a.read_len],
                        revcomp(genome[pos + 240:pos + 240 + a.read_len])))
        return out

    # Same sample across two lanes — the concatenation fixture.
    for lane in (1, 2):
        pairs = gene_pairs(a.n_pairs)
        write_fastq(f"{a.fastq_dir}/pe_L{lane}_1.fastq.gz", [x for x, _ in pairs])
        write_fastq(f"{a.fastq_dir}/pe_L{lane}_2.fastq.gz", [y for _, y in pairs])

    write_fastq(f"{a.fastq_dir}/se.fastq.gz",
                [x for x, _ in gene_pairs(a.n_pairs + 100)])
    write_fastq(f"{a.fastq_dir}/se_rrna.fastq.gz",
                [genome[RRNA_START + i * 10: RRNA_START + i * 10 + a.read_len]
                 for i in range(30)])

    # Small genome => the STAR SA index must shrink; 14 would blow up or fail.
    with open(f"{a.outdir}/config.sh", "w") as f:
        f.write(
            'ASSEMBLY=testasm\n'
            'ENSEMBL_RELEASE=0\n'
            'ORG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"\n'
            'GENOME_FA="${ORG_DIR}/genome.fa"\n'
            'GENOME_GTF="${ORG_DIR}/genes.gtf"\n'
            'GENOME_INDEX_DIR="${ORG_DIR}/index/star"\n'
            'RRNA_FA="${ORG_DIR}/contaminant_ref/rrna.fa"\n'
            'RRNA_INDEX="${ORG_DIR}/contaminant_ref/index/rrna"\n'
            'MANIFEST="${ORG_DIR}/MANIFEST.tsv"\n'
            'INTRON_MAX=1000\n'
            'SA_INDEX_NBASES=8\n'
        )

    abs_fq = os.path.abspath(a.fastq_dir)
    with open(f"{a.fastq_dir}/samples.tsv", "w") as f:
        f.write(f"pe_sample\t{abs_fq}/pe_L1_1.fastq.gz,{abs_fq}/pe_L1_2.fastq.gz\n")
        f.write(f"pe_sample\t{abs_fq}/pe_L2_1.fastq.gz,{abs_fq}/pe_L2_2.fastq.gz\n")
        f.write("# comment line\tignored\n")
        f.write(f"se_sample\t{abs_fq}/se.fastq.gz\n")
        f.write(f"rrna_sample\t{abs_fq}/se_rrna.fastq.gz\n")

    print(f"organism : {a.outdir}")
    print(f"reads    : {a.fastq_dir}")
    print(f"map      : {a.fastq_dir}/samples.tsv")
    print()
    print("Expected on a correct pipeline:")
    print(f"  pe_sample   -> {2 * a.n_pairs} pairs "
          f"({4 * a.n_pairs} records) — HALF this means the sample map overwrites")
    print("  se_sample   -> aligns, 0.00% rRNA")
    print("  rrna_sample -> ~100% rRNA, 0 aligned reads")
    print("  ReadsPerGene.out.tab: forward-only reads => col3 >> col4")


if __name__ == "__main__":
    main()
