# MP2-style candidates (logistic regression · train/val/test · ROC · doctor-threshold model · linear-regression test)

Modelled on Mini-Project 2: predict ICU death with logistic regression, build/read an ROC curve, and the "doctor reviewing 25 charts" cost model with $P(\text{fail}) = \exp(-t^2/100)$. Numbers are kept simple so the arithmetic is doable on paper.

---

### Q1 — Split the data and fit the model (8 pts)

`full.dat` has a 0/1 outcome `death` and feature columns. Write R that (a) splits the rows into training / validation / test sets (roughly 60/20/20) using index sampling, and (b) fits a logistic regression of `death` on `HR`, `age`, and `Gender` using the training set.

*Answer.*
```r
n   <- nrow(full.dat)
idx <- sample(1:n)
tr  <- idx[1:(0.6*n)]; va <- idx[(0.6*n+1):(0.8*n)]; te <- idx[(0.8*n+1):n]
train <- full.dat[tr, ]; val <- full.dat[va, ]; test <- full.dat[te, ]
model <- glm(death ~ HR + age + Gender, family = binomial, data = train)
```
Marking: a `sample`-based partition into three disjoint sets + a correct `glm(..., family = binomial)`. Exact proportions don't matter.

---

### Q2 — Accuracy vs. the base rate (8 pts)

Your model is correct on 86% of validation patients. 86% of patients survived. Is the model useful? Explain, and name a better thing to look at.

*Answer.* Not necessarily — "always predict survives" already scores 86% (the **base rate**). Accuracy is misleading under class imbalance. Compare against the base rate, and look at the trade-off between true-positive and false-positive rates (the ROC), or at sensitivity/PPV for the rare "death" class. Marking: identify the base rate, say accuracy alone is uninformative here, propose ROC / sensitivity.

---

### Q3 — Code an ROC point (10 pts)

Given a vector `p` of predicted death probabilities and the matching 0/1 truth `y`, write a function `rates(thr)` that returns the False Positive Rate and True Positive Rate when patients with `p > thr` are flagged. Then say how you'd get the whole ROC curve.

*Answer.*
```r
rates <- function(thr) {
  pred <- p > thr
  TPR <- sum(pred & y == 1) / sum(y == 1)
  FPR <- sum(pred & y == 0) / sum(y == 0)
  c(FPR = FPR, TPR = TPR)
}
```
ROC: `sapply(seq(0, 1, length.out = 100), rates)` and plot TPR (y) vs FPR (x). Marking: correct TPR = caught deaths / all deaths, FPR = false alarms / all survivors; sweeping the threshold for the curve.

---

### Q4 — Read the ROC (8 pts)

You're shown an ROC curve. (a) Roughly read off the FPR needed to correctly identify 90% of patients who will die. (b) Why might such a high FPR be acceptable here?

*Answer.* (a) Go to TPR = 0.90 on the y-axis, read the curve's x-value (the FPR) — expect it to be fairly high (e.g. ~0.4–0.6). (b) Missing a death (false negative) is far costlier than a false alarm (a survivor flagged for a closer look); in a screening/triage setting you accept many false positives to avoid missing real risk. Marking: correct axis reading + the asymmetric-cost argument.

---

### Q5 — Predicted probability by hand (8 pts)

A fitted logistic model is $\operatorname{logit} P(\text{death}) = -3 + 0.04\,\text{age} + 0.5\,\text{male}$. For a 50-year-old man, compute $P(\text{death})$ and state whether he is flagged at threshold 0.2.

*Answer.* Linear predictor $= -3 + 0.04(50) + 0.5(1) = -0.5$. $P = \sigma(-0.5) = 1/(1+e^{0.5}) \approx 0.38$. Since $0.38 > 0.2$, **flagged**. Marking: correct linear predictor, apply `plogis`/sigmoid, compare to threshold. (Accept $\approx 0.37$–0.38.)

---

### Q6 — Baseline expected deaths in the doctor model (10 pts)

A doctor has 60 minutes for 25 charts and reviews each for an equal time $t$ minutes. The chance of missing the right treatment after $t$ minutes on a chart is $P(\text{fail}) = \exp(-t^2/100)$. Of the 25 patients, 10 will die without correct intervention. How many of those 10 are expected to die?

*Answer.* $t = 60/25 = 2.4$ min. $P(\text{fail}) = \exp(-2.4^2/100) = \exp(-0.0576) \approx 0.944$. Expected deaths $= 10 \times 0.944 \approx 9.4$. Marking: $t = 60/25$, plug into $\exp(-t^2/100)$, multiply by 10. (The point: with so little time per chart the doctor barely helps.)

---

### Q7 — The threshold policy and its trade-off (10 pts)

Instead of reviewing everyone, the doctor reviews only patients whose predicted death probability exceeds a threshold `thr`, splitting the same total time equally among just those charts. (a) In words, what is the trade-off as `thr` rises? (b) Write R that computes expected deaths as a function of `thr` and picks the best threshold.

*Answer.* (a) Higher `thr` ⇒ fewer charts ⇒ more time each ⇒ lower $P(\text{fail})$ on the ones reviewed — **but** anyone below `thr` is never reviewed and dies if they were going to. Too low wastes time on everyone; too high abandons real cases. There's an interior optimum.
```r
total_time <- (N/25) * 60
exp_deaths <- function(thr) {
  reviewed <- which(p > thr)
  t  <- if (length(reviewed)) total_time / length(reviewed) else 0
  pf <- exp(-t^2 / 100)
  # reviewed at-risk patients may still die at rate pf; unreviewed at-risk all die
  sum(y[reviewed] == 1) * pf + sum(y[-reviewed] == 1)
}
thr_grid <- seq(0, 1, 0.001)
thr_grid[which.min(sapply(thr_grid, exp_deaths))]
```
Marking: the time-vs-coverage trade-off in (a); a `which.min` over a threshold grid in (b). Exact bookkeeping of the death count can vary; reward the structure.

---

### Q8 — Why evaluate on the test set, and lives saved (8 pts)

You picked the best threshold using the validation set. Explain why the final "lives saved vs. reviewing everyone" number is reported on the **test** set, and how you'd express it as a percentage.

*Answer.* The threshold was *tuned* on validation, so validation performance is optimistically biased (you chose the best-looking point); the untouched test set gives an honest estimate. Report $100\times(\text{deaths}_{\text{review-all}} - \text{deaths}_{\text{best policy}})/\text{deaths}_{\text{review-all}}$ on the test set. Marking: tuning ⇒ optimistic bias ⇒ need a held-out set; correct relative-reduction formula.

---

### Q9 — Critique the assumptions (8 pts)

The doctor-impact simulation rests on several assumptions. State two, and for each give a concrete situation where it fails.

*Answer.* Any two, e.g.: (i) $P(\text{fail}) = \exp(-t^2/100)$ is **made up** — real diagnostic accuracy may not follow that curve (some cases are hard no matter the time). (ii) "Correct intervention ⇒ patient lives" — interventions can fail or harm. (iii) Equal time per chart — triage isn't uniform. (iv) The model's probabilities are well-calibrated / patients are independent. Marking: 2 genuine assumptions, each with a plausible failure scenario (mirrors MP2 Part 6).

---

### Q10 — Linear-regression hypothesis test with assumption checks (12 pts)

(MP2 Part 7 in miniature.) You have two continuous columns `x` and `y`. Lay out how you would (a) state a null hypothesis, (b) check the model assumptions before trusting the test, (c) run the test in R, and (d) state a conclusion.

*Answer.* (a) $H_0: a_1 = 0$ in $y = a_0 + a_1 x + \varepsilon$. (b) Plot `y` vs `x` for linearity; fit `m <- lm(y ~ x)` and look at `plot(m)` — residuals-vs-fitted for linearity/constant variance, the Q–Q plot for normal residuals, and check for influential points. (c) read the p-value for the `x` coefficient from `summary(m)`. (d) e.g. "p = 0.002 < 0.05, so we reject $H_0$; the data are consistent with a positive association, though this is not by itself causal." Marking: a stated $H_0$; assumption checks named with the right diagnostic plot; `lm` + reading the coefficient p-value; a calibrated conclusion (reject/again no causation claim).
