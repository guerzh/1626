# Lecture candidates (probability · hypothesis testing · p-value pitfalls · regression · logistic · CIs · diagnostics · "truth about regression")

Drawn from lecture material through ~May 22 (Test-1 scope). Conceptual + short-derivation questions, the "30%" complement to the MP1/MP2 questions.

---

### Q1 — Bayes' rule / positive predictive value (8 pts)

A disease affects 1% of a population. A test is 95% sensitive ($P(+\mid\text{disease})=0.95$) and 95% specific ($P(-\mid\text{no disease})=0.95$). A random person tests positive. What is the probability they have the disease?

*Answer.* $P(D\mid +) = \dfrac{0.95\cdot 0.01}{0.95\cdot 0.01 + 0.05\cdot 0.99} = \dfrac{0.0095}{0.0095+0.0495} \approx 0.16$. Marking: correct Bayes setup; the point is that with a rare disease most positives are false positives. (Accept ≈ 0.16.)

---

### Q2 — Conditional-probability puzzle (6 pts)

A family has two children. Given that **at least one is a boy** (each child independently a boy or girl with probability 1/2), what is the probability that **both** are boys?

*Answer.* Sample space $\{BB, BG, GB, GG\}$; condition on "at least one boy" removes $GG$, leaving 3 equally likely; only $BB$ is "both boys": $1/3$. Marking: enumerate, condition correctly, $1/3$ (not 1/2). Good place to test that conditioning changes the sample space.

---

### Q3 — A p-value by simulation (10 pts)

Two groups of beak depths (1976 vs 1978) have observed mean difference `d_obs`. Using only **simulation** (no t-distribution), describe and write code to get a p-value for $H_0:$ the two years have the same distribution. State whether you'd use a one- or two-sided p-value and why.

*Answer.* Pool all depths; under $H_0$ the year label is irrelevant, so repeatedly **shuffle** labels (or resample from a common model), recompute the mean difference, and build its null distribution.
```r
sim <- replicate(5000, {
  shuffled <- sample(year)                       # permute labels
  mean(depth[shuffled == 1978]) - mean(depth[shuffled == 1976])
})
mean(abs(sim) >= abs(d_obs))                      # two-sided p-value
```
Two-sided unless you had a prior reason the difference can only go one way. Marking: a permutation/resampling scheme under $H_0$, `replicate`, p-value as a tail fraction; sensible one-vs-two-sided answer.

---

### Q4 — What a p-value is (and error types) (8 pts)

(a) A study reports $p = 0.03$. Which of these is correct? (i) There's a 3% chance $H_0$ is true. (ii) If $H_0$ were true, data this extreme would occur 3% of the time. (b) Define a Type I and a Type II error in one line each. (c) What do "Type S" and "Type M" errors add?

*Answer.* (a) (ii) is correct; (i) is the classic misinterpretation — a p-value is computed *assuming* $H_0$. (b) Type I = rejecting a true $H_0$ (false positive); Type II = failing to reject a false $H_0$ (miss). (c) Type S = getting the **sign** of the effect wrong; Type M = **magnitude** — overestimating the effect size (common with low-powered "significant" studies). Marking: 4 for (a)+(b), 4 for the S/M distinction.

---

### Q5 — Multiple comparisons / replication (8 pts)

A lab runs 20 independent tests at the 5% level on data where, in truth, **no** effect exists anywhere. (a) How many "significant" results do you expect? (b) Briefly connect this to the "garden of forking paths" and to why splashy low-powered findings often fail to replicate.

*Answer.* (a) $20 \times 0.05 = 1$ false positive on average. (b) If you (or the field) try many analyses/subgroups and report the significant ones, false positives are almost guaranteed; the "forking paths" make the effective number of tests large even without explicit p-hacking. Low-powered studies that *do* clear significance tend to have exaggerated effect sizes (Type M), so they don't replicate. Marking: expected count = 1; the multiplicity + Type-M-ish replication point.

---

### Q6 — Interpreting a regression table with an indicator (10 pts)

`lm(weight ~ height + sexMale)` (sex coded with female as baseline) gives intercept $-100$, `height` coefficient $1.1$, `sexMale` coefficient $5$. Interpret each of the three numbers.

*Answer.* Intercept: predicted weight for a female of height 0 (not physically meaningful — an extrapolation). `height` = 1.1: holding sex fixed, each additional unit of height adds 1.1 to predicted weight. `sexMale` = 5: at the same height, males are predicted 5 heavier than females (the baseline). Marking: "holding the other fixed" for the slope; the indicator as a shift relative to the baseline category; intercept as the baseline at zero predictors.

---

### Q7 — R², correlation, and Anscombe (10 pts)

(a) Define $R^2$ as a comparison between two predictors and give the formula. (b) If $\text{SSE}_{\text{model}} = 30$ and $\text{SSE}_{\text{baseline}} = 200$, compute $R^2$ and the correlation $r$ (single predictor, positive slope). (c) What is the one-sentence lesson of Anscombe's quartet?

*Answer.* (a) $R^2 = 1 - \text{SSE}_{\text{model}}/\text{SSE}_{\text{baseline}}$, comparing the regression to predicting the mean $\bar y$ every time. (b) $R^2 = 1 - 30/200 = 0.85$; $r = +\sqrt{0.85} \approx 0.92$. (c) A single $R^2$/$r$ can come from wildly different pictures (outliers, nonlinearity) — **always visualize**. Marking: formula + baseline = "predict the mean"; arithmetic; signed square root; the visualize lesson.

---

### Q8 — Sigmoid and the confusion matrix (10 pts)

(a) Write the sigmoid (logistic) function. (b) A classifier on 100 patients produces: of 20 true deaths, 14 are flagged; of 80 survivors, 8 are flagged. Compute accuracy, TPR (sensitivity), FPR, and PPV. (c) Why can accuracy look good here even for a weak model?

*Answer.* (a) $\sigma(z) = 1/(1+e^{-z})$. (b) TP=14, FN=6, FP=8, TN=72. Accuracy $=(14+72)/100 = 0.86$; TPR $=14/20 = 0.70$; FPR $=8/80 = 0.10$; PPV $=14/(14+8) = 0.64$. (c) Survivors dominate (base rate 0.80), so high accuracy is cheap; the rare class is what matters. Marking: sigmoid; correct four counts and rates; base-rate point.

---

### Q9 — Confidence intervals (8 pts)

(a) In one sentence, what does a 95% confidence interval mean — and what does it **not** mean? (b) A `glm` coefficient has estimate $0.40$ and standard error $0.15$. Give an approximate 95% CI and say whether you'd reject $H_0:$ coefficient $=0$ at the 5% level.

*Answer.* (a) Over repeated samples, 95% of such intervals contain the true parameter; it is **not** "95% probability the true value is in this particular interval." (b) $0.40 \pm 1.96(0.15) = 0.40 \pm 0.29 = (0.11,\ 0.69)$. It excludes 0, so reject at 5% (CI ↔ p-value duality). Marking: correct frequentist meaning + the caveat; $\pm 1.96\,\text{SE}$; CI-excludes-0 ⇒ reject.

---

### Q10 — Omitted variables, controls, and a "creative" scenario (12 pts)

(a) Explain omitted-variable bias with a one-line example. (b) When someone reports "the gender wage gap, **controlling for** occupation," what does adding the control change about the claim? (c) *Creative:* describe a situation where encoding a predictor as a **categorical** variable would fit much better than treating it as **continuous**, and say why.

*Answer.* (a) Ice-cream sales "predict" drownings because both are driven by hot weather (the omitted common cause) — the raw association isn't causal. (b) It estimates the gap *within* occupations rather than overall; it answers a different question and can shrink, grow, or flip the headline number depending on whether occupation is a confounder or a mediator. (c) Any non-monotone/non-linear effect, e.g. month-of-year on heating cost, or a U-shaped age effect: the continuous term forces a single slope, while one indicator per category lets each level have its own mean. Marking: a genuine common-cause example; "controls change the estimand / within-group comparison"; a sensible categorical-beats-continuous scenario with the "lets each level move freely" reasoning.
