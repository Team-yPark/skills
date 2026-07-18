# domain-expert-learning — Reference

Loaded only when `SKILL.md` points here.

## Area taxonomy

Top-level directories under `domain-knowledge/`. Pick the area the fact is
*about*, not the task you happened to be doing when you learned it.

| Area | Holds | Examples |
|---|---|---|
| `biology` | organisms, cells, physiology, development, evolution | cell cycle phases; C. elegans life stages; what a ribosome does |
| `biochemistry` | molecules, reactions, structures, kinetics | codon table; enzyme mechanisms; nucleotide chemistry |
| `genetics` | inheritance, variation, gene regulation | dominance; linkage; imprinting; allele notation |
| `genomics` | genome structure, references, annotation | assembly builds; seqname conventions; biotype vocabularies |
| `bioinformatics` | tools, formats, algorithms, parameters | STAR flags; FASTQ/BAM/GTF formats; aligner trade-offs |
| `statistics` | methods used to analyse the above | multiple testing; dispersion estimation; normalisation |

The boundaries blur (a codon table is biochemistry and genetics). Put it in one
place, `tag` the others, and `[[link]]` across. Do not duplicate the fact into
two areas — one canonical entry, linked.

Add a new area only when several entries need it and none of the above fits
(e.g. `proteomics`, `structural-biology`). A lone entry in a new area is a sign
it belongs in an existing one.

## Worked capture example

**Trigger:** while building a Ribo-seq aligner call you are unsure why STAR's
default `--alignIntronMax` corrupts a compact-genome alignment.

**Research:** STAR manual (`--alignIntronMax` default 0 → computed as
`winBinNbits * winAnchorDistNbins`, effectively very large); plus empirical
observation that a nematode/insect genome has introns far shorter than a
mammalian one.

**Distil** to the load-bearing claim and write
`genomics/alignintronmax-by-genome-compactness.md`:

```markdown
---
title: alignIntronMax must scale to genome intron length
area: genomics
tags: [star, alignment, intron, genome-size]
confidence: established
updated: 2026-07-18
sources:
  - STAR manual (alexdobin/STAR), --alignIntronMax section
  - verified empirically, BCbB worm vs mouse setup, 2026-07
---

## Fact
An aligner's maximum-intron parameter must match the target genome's intron
length distribution. Compact genomes (nematode, insect, fungal) have short
introns and closely spaced genes; a large max-intron value lets a spliced read
bridge two unrelated genes. Typical: ~25 kb for C. elegans, ~1 Mb (STAR default)
for mammals, 1 (no splicing) when aligning to a CDS/transcript FASTA.

## Why it matters
Wrong value produces no error — just wrong alignments. On a compact genome the
mammalian default silently joins neighbouring genes.

## Caveats
Derive from the actual intron distribution, not a copied constant. "Compact" is a
spectrum; 25 kb suits C. elegans, other small genomes differ.

## See also
[[fastq-gzip-multimember-concatenation]]
```

Then add to `INDEX.md` and run the validator.

Note what was discarded: the manual's full parameter prose, the exact default
formula, the forum threads. What survived is the rule, the numbers, and the
failure mode — with sources so it can be re-checked.

## Source quality for this domain

Roughly best-to-worst; prefer higher when they conflict:

1. **Official tool docs / man pages / source** — for tool behaviour, definitive.
2. **Database documentation** (Ensembl, NCBI, UniProt, WormBase) — for formats,
   identifiers, conventions.
3. **Textbooks / reviews** — for established mechanisms and definitions.
4. **Peer-reviewed primary papers** — for methods and findings; note that a
   single paper is evidence, not consensus.
5. **Your own verified experiment** — strong for tool behaviour you tested; cite
   *where and when*, and label it as empirical.
6. **Blogs, forums, Q&A** — a pointer, not a citation. Chase them to a primary
   source before writing the entry.

Two domain-specific hazards to record when relevant:

- **Version/release drift.** Genome builds (GRCh37 vs 38), annotation releases,
  and tool versions change behaviour. Pin the version in the entry when it
  matters, and set `updated` honestly.
- **Nomenclature clashes.** The same name means different things across sources
  (gene symbols vs IDs; `gene_biotype` vs `gene_type`; `1` vs `chr1`). When an
  entry hinges on a name, say which convention.

## Maintenance

- **Dedup on write** — search INDEX and `grep` the areas before adding.
- **Correct in place** — when a fact is superseded, edit the entry and bump
  `updated`; do not leave a stale duplicate.
- **Prune** — delete entries that turn out wrong or that are project-specific and
  slipped in. Remove the INDEX line too.
- **Validate** — `python3 <skill dir>/domain-knowledge/validate.py` after any change; it is
  the cheap guard against INDEX drift and malformed frontmatter.
