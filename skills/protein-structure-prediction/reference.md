# protein-structure-prediction — Reference

Model details, input/output formats, and tooling. Capabilities and versions move
fast — verify against current docs before relying on a specific number.

## Model comparison

| Model | Input | Predicts | MSA? | Access | Notes |
|---|---|---|---|---|---|
| **AlphaFold2** (Jumper 2021) | sequence | single chain (+Multimer for complexes) | yes | open weights; ColabFold | CASP14 breakthrough; highest single-chain accuracy |
| **ColabFold** (Mirdita 2022) | FASTA | AF2/Multimer | yes (MMseqs2, fast) | notebook + `colabfold_batch` | the accessible AF2; 40–60× faster MSA |
| **AlphaFold3** (Abramson 2024) | seq + ligand/NA | proteins + DNA/RNA/ligand/ion complexes | light | AF Server (usage-limited) + released code | diffusion decoder; per-atom pLDDT |
| **Boltz** (Boltz-1 2024, Boltz-2 2025) | YAML (chains + SMILES) | AF3-class complexes, ligand pose, affinity (Boltz-2) | optional (`--use_msa_server`) | **open source**, `pip install boltz` | local AF3 alternative |
| **ESMFold** (Lin 2023) | single sequence | single chain | **no** | open weights; ESM Atlas API | ESM-2 LM; ~10× faster; better on orphans |

Also: **RoseTTAFold / RoseTTAFold All-Atom**, **OmegaFold** (single-sequence),
**AlphaFold-Multimer** (AF2 complexes). Foldseek/TM-align/US-align for comparison.

## Confidence scores (recap; full entry in the knowledge base)

| Score | Scale | Reads |
|---|---|---|
| pLDDT | 0–100 per residue (per atom in AF3), in B-factor column | local folded-ness; >90 high, <50 disordered |
| PAE | Å, residue×residue matrix (JSON) | relative position error; inter-domain/chain reliability |
| pTM / ipTM | 0–1 | global fold / interface confidence; ipTM > ~0.8 = reliable interface |

## Input formats

**FASTA (ColabFold / AF2)** — one record per prediction; for a complex, join chains
with a colon:
```
>my_complex
MKT...AAA:MQI...GGG
```

**Boltz YAML** — chains and ligands:
```yaml
version: 1
sequences:
  - protein: {id: A, sequence: "MKT...AAA"}
  - ligand:  {id: L, smiles: "CC(=O)Oc1ccccc1C(=O)O"}
```

**ESMFold API** — raw sequence string in the POST body (length-limited; long
sequences need local/GPU).

## Output files

- **`.pdb` / `.cif`** — atomic coordinates; **pLDDT is stored in the B-factor
  column** (colour by it in PyMOL/ChimeraX).
- **PAE JSON** (`*_predicted_aligned_error*.json` / scores JSON) — the PAE matrix;
  plot it as a heatmap.
- **Ranked models** — tools emit several (e.g. 5) ranked by confidence; rank_0 is
  the top model, but inspect the spread.

## Databases to check before predicting

- **PDB** — rcsb.org (experimental structures).
- **AlphaFold DB** — alphafold.ebi.ac.uk (precomputed AF2 by UniProt).
- **ESM Metagenomic Atlas** — esmatlas.com.

## Compute reality

- **GPU required** for practical runtimes; CPU folding is impractical for real
  proteins.
- MSA-based tools need large sequence databases (UniRef/BFD, 100s of GB) unless you
  use a remote MSA server (ColabFold's MMseqs2, Boltz `--use_msa_server`).
- Weights are downloaded once (GB-scale). A single prediction is minutes on GPU
  once set up; setup and databases are the slow part.
- Long sequences and large complexes are memory-bound (VRAM); split or use
  reduced-precision/low-VRAM modes.

Because of the above, this skill's job is to choose the tool, prepare inputs, and
interpret outputs — **print run commands for the user**, don't attempt a full
prediction inline.
