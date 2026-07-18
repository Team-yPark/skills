---
name: protein-structure-prediction
description: Predict and analyze a protein's 3D structure from its amino-acid sequence — choose the right model (AlphaFold2/ColabFold, AlphaFold3, Boltz, ESMFold), get a structure, and interpret the result. Use when the task involves protein structure from sequence, folding a protein, a FASTA/UniProt sequence → structure, protein complexes or protein-ligand poses, or reading pLDDT/PAE confidence — keywords include AlphaFold, AlphaFold2, AlphaFold3, ColabFold, Boltz, ESMFold, ESM, fold this protein, predict structure, pLDDT, PAE, PDB structure, protein complex, docking, structure prediction.
---

# Protein Structure Prediction from Sequence

Turn an amino-acid sequence into a usable 3D structure: pick a model for the job,
obtain the structure (look it up before predicting), and interpret it through its
confidence scores. Background biochemistry and model facts live in the knowledge
base (`be-domain-expert`, `biochemistry/` and `bioinformatics/protein-structure/`);
this skill is the practical how-to.

## First: does the structure already exist?

Predicting is often unnecessary. Check, in order:

1. **PDB** (rcsb.org) — an experimental structure (X-ray/cryo-EM/NMR) beats a
   prediction; search by sequence (BLAST) or ID.
2. **AlphaFold DB** (alphafold.ebi.ac.uk) — 200M+ precomputed AF2 models, keyed by
   UniProt accession. If your protein is there, download it (`.pdb` + PAE JSON)
   instead of re-running.
3. **ESM Metagenomic Atlas** — for metagenomic/orphan sequences.

Only predict when there is no suitable existing model, the sequence is novel
(variant, designed, chimera), or you need a **complex/ligand** state not in a DB.

## Choose the model

| Situation | Use | Why |
|---|---|---|
| Single protein, has homologs (deep MSA) | **ColabFold / AlphaFold2** | highest single-chain accuracy |
| Protein **complex** (multi-chain), or with **DNA/RNA/ligand/ion** | **AlphaFold3** or **Boltz** | model the whole assembly, not lone chains |
| Open/local complex + ligand, at scale | **Boltz** (Boltz-1/2) | open-source AF3-class; runs locally |
| Many sequences / need speed / **orphan** or **designed** protein | **ESMFold** | no MSA, ~10× faster, better on shallow-MSA |
| Just a quick single fold, no setup | ESMFold API or ColabFold notebook | zero install |

Decision rationale (MSA depth, complexes, speed/accuracy trade-offs) is in the
knowledge base — consult `be-domain-expert` if unsure which applies.

## Get a structure

Prefer a hosted notebook/API for one-offs; local install for batches.

**ColabFold (AF2, MSA via MMseqs2)** — the standard accessible AF2:
```bash
# local: github.com/sokrypton/ColabFold  (needs GPU + colabfold_batch)
colabfold_batch input.fasta out_dir/    # FASTA: one record per chain
#   complex: put chains in one record separated by ':'  (SEQ1:SEQ2)
```

**ESMFold (single sequence, no MSA)** — fast, via API or transformers:
```bash
# hosted API (short sequences), no install:
curl -X POST --data "<AA_SEQUENCE>" https://api.esmatlas.com/foldSequence/v1/pdb/ > pred.pdb
```

**Boltz (open AF3-class, complexes + ligands)**:
```bash
pip install boltz
boltz predict input.yaml --use_msa_server   # YAML lists protein chains + ligand SMILES
```

**AlphaFold3** — via the AlphaFold Server (usage-limited, non-commercial) or a
local install of the released code+weights (heavy: GPU, large databases).

Running any of these for real needs a **GPU** and, for MSA-based tools, large
sequence databases (100s of GB) — hours of setup/compute. **Print the command and
let the user run it**; do not assume you can execute a full prediction here.

## Interpret the result — always with confidence scores

Never take a predicted `.pdb` at face value. Colour by confidence and read the PAE:

- **pLDDT** (per-residue, in the B-factor column): >90 high, 70–90 good backbone,
  50–70 low, **<50 likely disordered** (not a real fold — don't interpret its
  shape).
- **PAE** (residue×residue map, in the output JSON): low **inter-domain / inter-
  chain** PAE = trustworthy relative arrangement; high = the domains'/partners'
  placement is uncertain even if each is well-folded. **Judge complexes and domain
  packing by PAE/ipTM, not pLDDT.**
- **ipTM > ~0.8** suggests a reliable interface in a complex.

Full interpretation guidance: `bioinformatics/protein-structure/structure-confidence-plddt-pae.md`.

## Downstream analysis

- **Visualize** — PyMOL / ChimeraX / Mol*; colour by pLDDT; overlay the PAE plot.
- **Split by domain** before interpreting a large multi-domain protein (high
  inter-domain PAE means the arrangement is not reliable).
- **Compare structures** — TM-align / US-align (TM-score, fold similarity),
  **Foldseek** for fast structure search against the PDB/AF DB, RMSD after
  superposition.
- **Complexes/ligands** — inspect the interface and ligand pose; validate against
  known biology; a plausible pose is not a proven one.

## Pitfalls

1. **Predicting when a structure exists** — check PDB / AlphaFold DB first.
2. **Trusting pLDDT for domain/complex arrangement** — that is PAE's job.
3. **Reading dynamics/function/mutation-effects off one static model** — the model
   is a single most-likely conformation, not an ensemble or the bound state.
4. **Ignoring MSA depth** — an orphan protein's AF2 model may be low-confidence no
   matter how simple it looks; consider ESMFold and expect lower confidence.
5. **High confidence ≠ correct** — confidently-wrong cases exist (e.g. repeat
   proteins); sanity-check against biology.
6. **Assuming you can run it here** — it is GPU/hours; hand the user the command.

## Reference

`reference.md` — model comparison table with versions/access, input-format details
(FASTA multi-chain, Boltz YAML, ligand SMILES), output files, and tool pointers.
