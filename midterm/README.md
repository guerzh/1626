# Midterm (Test 1) — candidate question bank

Draft pool of candidate questions for the May 29 midterm (~1 h 10 min, **open handout** — the [test reference sheet](../website/materials/1626s26/test_reference.pdf) is provided, so no syntax to memorize).

Three files, 10 candidates each:

- [`mp1_candidates.md`](mp1_candidates.md) — similar to Mini-Project 1 (tidyverse, probability, MLE, Bayesian inference, low p-values).
- [`mp2_candidates.md`](mp2_candidates.md) — similar to Mini-Project 2 (logistic regression, train/val/test, ROC, the doctor-threshold cost model, linear-regression hypothesis test).
- [`lecture_candidates.md`](lecture_candidates.md) — taken from lecture.

## Weighting (as announced in lecture)

≈ **70% MP1 + MP2**, **30% lecture**, plus possibly one "creative" scenario question. So a real paper would pull mostly from the MP1/MP2 files and round it out from the lecture file.

## Scope caveat — what is *out*

The May 27 lecture is **not on Test 1** (the instructor said so explicitly). So nothing here uses:

- the theoretical/closed-form **t-test** (Student's $t$, `pt`, `t.test`) — only the **simulation** route to a p-value is fair game;
- **Fisher's exact test** / Lady Tasting Tea;
- **hierarchical / multilevel models**;
- the **LLM text-analysis workshop** (`notopenai`, embeddings, clustering);
- **causal inference** / DAGs.

Everything below is from MP1, MP2, or lecture material through ~May 22.

## Conventions

- Each question has a suggested point value and an *Answer / marking* sketch.
- "Write code" means short R that a student could write on paper; verb signatures (`group_by`, `summarize`, `glm`, `sample`, `replicate`, `plogis`, …) are on the reference sheet.
- Students are **not** required to write `ggplot` syntax — plotting questions ask them to *describe* or *read* a plot.
