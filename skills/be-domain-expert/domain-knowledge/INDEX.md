# Domain Knowledge — Index

One line per entry. Scan this first during recall; open the entries that match.
Format: `- [title](path) — hook [confidence, updated]`.

Areas may nest (e.g. `bioinformatics/RIBO-seq/`). Keep this in sync with the
files — an entry missing here is invisible to recall.
`python3 validate.py` checks it.

## biology

- [Molecular heterogeneity tends to increase with age](biology/molecular-noise-increases-with-age.md) — cell/sample dispersion (transcriptional noise, entropy) rises with age even at stable means; mean-variance confounded [emerging, 2026-07-18]

## biochemistry

- [Ribosome footprint length is ~28–30 nt](biochemistry/ribosome-footprint-length.md) — the ribosome protects a discrete ~28–30 nt mRNA fragment; the basis of Ribo-seq and of trim windows [established, 2026-07-18]

## genetics

_(none yet)_

## genomics

- [Genome sequence-name conventions differ by source](genomics/reference-seqname-conventions.md) — Ensembl `1` vs UCSC `chr1` vs NCBI `NC_…` vs WormBase roman numerals; mismatched FASTA/GTF aligns nothing [established, 2026-07-18]

## bioinformatics

- [Concatenating gzipped FASTQs with cat is valid](bioinformatics/fastq-gzip-multimember-concatenation.md) — gzip is multi-member; `cat a.gz b.gz` merges lanes losslessly, no re-compress [established, 2026-07-18]
- [STAR --genomeSAindexNbases must shrink for small references](bioinformatics/star-genomesaindexnbases-small-genome.md) — default 14 suits mammals; small genome/transcript ref needs `min(14, log2(L)/2-1)` [established, 2026-07-18]
- [Cross-annotation gene-ID mapping needs a multi-tier fallback](bioinformatics/gene-id-mapping-multitier.md) — direct string match fails for ~half of genes across Ensembl/NCBI/releases; layer symbol → BioMart → gene2ensembl [established, 2026-07-18]
- [WGCNA — co-expression modules, eigengenes, and hub genes](bioinformatics/wgcna-coexpression-modules.md) — correlation → soft-threshold (scale-free) → TOM → modules → eigengene (PC1) → hub genes → module-trait [established, 2026-07-18]
- [Cell-type deconvolution of bulk omics via SVR](bioinformatics/bulk-deconvolution-svr.md) — CIBERSORT-style ν-SVR against a reference signature matrix; bulk change may be composition, not regulation [established, 2026-07-18]

### bioinformatics / RIBO-seq

- [3-nt periodicity is the defining Ribo-seq signal and QC metric](bioinformatics/RIBO-seq/three-nt-periodicity.md) — RPFs step one codon at a time; ≥~80% in-frame is the standard QC and evidence-of-translation signal [established, 2026-07-18]
- [P-site offset — definition and typical values](bioinformatics/RIBO-seq/psite-offset.md) — 5′-end→P-site codon distance, per read length; ~12 nt for 28–30 mers [established, 2026-07-18]
- [P-site offset calibration by start-codon metagene](bioinformatics/RIBO-seq/psite-offset-calibration.md) — riboWaltz two-step: per-length start-codon peak then cross-length coherence correction [established, 2026-07-18]
- [CDS-library alignment strategy for Ribo-seq](bioinformatics/RIBO-seq/cds-library-alignment.md) — align footprints to one-CDS-per-gene FASTA, unique-only, `--alignIntronMax 1`; removes isoform/paralog multimapping [established, 2026-07-18]
- [Trim one 5′ nucleotide from ligation-based small-RNA / Ribo-seq reads](bioinformatics/RIBO-seq/5prime-nontemplated-nt-trim.md) — RNA-ligation adds a non-templated 5′ base; `fastp --trim_front1 1` restores frame registration [established, 2026-07-18]
- [Translation efficiency (TE) and three-layer regulation classes](bioinformatics/RIBO-seq/translation-efficiency.md) — TE = log2(RPF)−log2(mRNA) normalized; deltaTE/anota2seq interaction models; transcriptional/translational/buffered/intensified [established, 2026-07-18]
- [Ribosome pause score — coverage over local mean](bioinformatics/RIBO-seq/pause-score.md) — per-codon density ÷ internal-CDS mean (excluding ±20 codons); localizes elongation slowdown [established, 2026-07-18]

## machine-learning

- [Nothing derived from held-out data may touch the model](machine-learning/data-leakage-in-cross-validation.md) — fit preprocessing inside each CV fold; select hyperparameters on training only, never the test/query set [established, 2026-07-18]
- [Autoencoders learn a compact representation; denoising adds robustness](machine-learning/autoencoder-representation-learning.md) — bottleneck reconstruction → reusable embedding; learn features unsupervised, fit a simple head for small-n labels [established, 2026-07-18]
- [Adversarial training removes a nuisance factor from a representation](machine-learning/adversarial-domain-invariance.md) — encoder vs a batch/domain discriminator (DANN / gradient reversal) → nuisance-invariant embedding [established, 2026-07-18]
- [Masked self-supervised pretraining learns features without labels](machine-learning/transformer-masked-pretraining.md) — BERT-style masked reconstruction on a Transformer; pretrain unlabelled, fine-tune a light head [established, 2026-07-18]

### machine-learning / aging-clocks

- [Transcriptomic aging clock — predict age from expression](machine-learning/aging-clocks/transcriptomic-aging-clock.md) — regress reference expression on age → transcriptomic age (tAge); the age-acceleration residual is the readout [established, 2026-07-18]
- [Elastic net is the standard aging-clock regression](machine-learning/aging-clocks/elastic-net-aging-clock.md) — L1+L2 penalty gives a sparse, stable gene panel from p≫n data; the Horvath-clock standard [established, 2026-07-18]
- [Principal component regression (PC) clocks reduce technical noise](machine-learning/aging-clocks/principal-component-regression-clock.md) — PCA→regression averages out uncorrelated noise, improving test–retest reliability [established, 2026-07-18]
- [BayesAge-style likelihood age prediction over an expression reference](machine-learning/aging-clocks/bayesage-likelihood-age-prediction.md) — max Poisson likelihood of counts vs a LOWESS age–expression reference; frequency-normalized input [emerging, 2026-07-18]
- [Transferring a clock to a new dataset requires batch correction](machine-learning/aging-clocks/clock-transfer-batch-correction.md) — batch-correct reference+query together (ComBat-seq on raw counts) or predictions are silently offset [established, 2026-07-18]

## proteomics

- [Proteomics missing values are mostly MNAR — impute in the left tail](proteomics/mnar-imputation.md) — below-detection missingness; Perseus down-shifted Gaussian N(μ−1.8σ, (0.3σ)²), not KNN/mean [established, 2026-07-18]
- [LFQ intensities are analyzed on the log2 scale](proteomics/lfq-log2-intensities.md) — label-free intensity is right-skewed; log2 makes it ~normal and fold-changes additive [established, 2026-07-18]
- [Differential protein expression uses a moderated t-test on log2 LFQ](proteomics/differential-protein-expression.md) — limma empirical-Bayes on small-n proteomics; Wilcoxon (Scanpy default) underpowered [established, 2026-07-18]

## statistics

- [Negative-binomial count models require raw counts, not TPM/CPM](statistics/count-models-need-raw-counts.md) — DESeq2/edgeR estimate size factors + dispersion internally; feeding TPM "runs" but is wrong [established, 2026-07-18]
- [DESeq2 median-of-ratios size-factor normalization](statistics/deseq2-median-of-ratios.md) — median of per-gene count ratios vs a geometric-mean reference; robust library-depth scaling [established, 2026-07-18]
- [Empirical-Bayes variance shrinkage rescues power at small replicate n](statistics/limma-empirical-bayes-small-n.md) — limma borrows variance across genes; effective df ~4 → >20 for n=3 [established, 2026-07-18]
- [Choose the batch-correction method by data type](statistics/batch-correction-by-data-type.md) — ComBat (log), ComBat-seq (counts), Harmony (embedding); never confound batch with biology [established, 2026-07-18]
- [Fit at the level of the independent unit, not its sub-samples](statistics/pseudoreplication.md) — worms-in-a-bin / cells-in-an-animal aren't independent; aggregate or use a mixed model [established, 2026-07-18]
- [Robust trend estimation — Theil–Sen slope and Mann–Kendall test](statistics/robust-trend-theil-sen-mann-kendall.md) — median-of-pairwise-slopes + monotone-trend test as small-n companions to OLS [established, 2026-07-18]
- [One-way ANOVA — F-test for three or more group means](statistics/one-way-anova.md) — between/within variance ratio; omnibus multi-group test; per-gene ANOVA underlies multi-group DE [established, 2026-07-18]
- [A significant ANOVA needs a post-hoc test to say which groups differ](statistics/anova-posthoc-multiple-comparisons.md) — Tukey HSD / Dunnett / Games–Howell / Dunn; not bare uncorrected pairwise t-tests [established, 2026-07-18]
- [Factorial (two-way) ANOVA and the interaction term](statistics/factorial-anova-interaction.md) — crossed factors + `A:B` interaction; the interaction (genotype×treatment) is often the biological question [established, 2026-07-18]
- [Kruskal–Wallis — rank-based ANOVA alternative](statistics/kruskal-wallis-nonparametric-anova.md) — non-parametric one-way ANOVA for non-normal/small-n data (eQTL, expression); Dunn post-hoc [established, 2026-07-18]
- [ANCOVA — ANOVA adjusted for a continuous covariate](statistics/ancova-covariate-adjustment.md) — test group effect holding age/RIN/depth fixed; ANOVA/ANCOVA/regression are one general linear model [established, 2026-07-18]
- [PERMANOVA — permutational multivariate ANOVA on a distance matrix](statistics/permanova-distance-based.md) — pseudo-F + R² by permutation on Bray–Curtis etc.; microbiome beta-diversity standard; check dispersion (PERMDISP) [established, 2026-07-18]
- [Repeated-measures / non-independent designs need mixed models](statistics/repeated-measures-mixed-model.md) — random effects for repeated/nested samples; plain ANOVA pseudoreplicates [established, 2026-07-18]
