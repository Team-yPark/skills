---
title: Masked self-supervised pretraining learns features without labels
area: machine-learning
tags: [transformer, self-supervised, masked-pretraining, bert, tokenization, embedding]
confidence: established
updated: 2026-07-18
sources:
  - Vaswani et al. 2017 (NeurIPS) — the Transformer
  - Devlin et al. 2019, BERT (NAACL) — masked-language-model pretraining
---

## Fact
A **Transformer** encoder maps a set/sequence of tokens to contextual embeddings
via self-attention. **Masked pretraining** (BERT-style) trains it self-supervised:
randomly hide a fraction of the input tokens and train the model to reconstruct
them from the rest. No labels are needed, so all available data drives feature
learning; the pretrained encoder (or its pooled `CLS`/mean embedding) is then
fine-tuned or frozen for a downstream supervised task. Non-text inputs are used by
**tokenizing** them first (e.g. ranking features and treating the top-k as tokens).

## Why it matters
It converts abundant unlabelled data into a strong representation, so a small
labelled set only has to train a light head — the same label-efficiency argument as
autoencoders, with attention capturing higher-order interactions between features.
It is the dominant paradigm for language and is increasingly applied to tabular and
omics data.

## Caveats
Transformers are **data- and compute-hungry** and overfit badly on small datasets
without heavy pretraining/regularization — often not worth it versus a linear or
tree model on a few hundred samples. Tokenizing continuous/tabular features is an
unsettled design choice (binning, ranking, embeddings) and application outside
text/vision is still **emerging** despite the technique being established. Evaluate
against strong simple baselines before assuming the transformer helps.

## See also
[[autoencoder-representation-learning]] · [[adversarial-domain-invariance]] · [[data-leakage-in-cross-validation]]
