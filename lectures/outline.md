# MIE1626 — Course Outline (so far)

Lectures covered: May 6, May 8, May 13, May 20, May 22.
(No class May 15 — Victoria Day.)

Within each lecture, topics are organized by subject matter, not by recording part. The course also includes a running project and two mini-projects; mini-project 1 was posted around May 16, mini-project 2 was previewed on May 22.

---

## Lecture 1 — May 6

### Course organization and goals
- Statistical inference with a more computational, less algebra-centric spin.
- The modern data-science workflow: agentic coding, acquire → analyze → present → suggest action.
- Coding practice in R and Python; reading data-science code.
- Four mini-projects (coding, LLM use allowed but you are tested on the content); two written tests; a course project with a light proposal and an in-term presentation/check-in.

### Why functional programming in R
- Writing `map(square, L)` instead of a `for` loop: think about transforming the input as if it were math, let the system schedule the work.
- It runs faster in R, it is how Pandas is normally used in Python, and it lines up with the statistical-inference material later in the course.

### R basics
- Literals, R as a calculator.
- `cat` vs `print`; printing multiple things.
- Variable assignment with `<-` (and `=`, and the right-arrow form).
- `if` / `else if` / `else`; parentheses and braces are mandatory.
- Defining functions; the value of the last expression is the return value (no `return` keyword needed).
- The "function is just a value" view: `my_abs <- function(x) ...` vs calling an anonymous function directly. Brief parallel to Python (`abs = 10`).
- Distinguishing printing from returning a value.

### Vectors
- `c(...)` to build a vector; 1-based indexing; ranges like `v[2:5]`; `length`, `sort`, `unique`, `min`, `max`.
- A scalar is a length-1 vector.
- Boolean vectors from comparisons (`offer > 533`), then indexing with a boolean vector to select elements.
- Combining conditions: `&`, `|`, `!`.
- "Pie or ice cream" example for exclusive vs inclusive OR.
- Worked example: find the specialty with the highest salary by combining a boolean mask with vector indexing; alternative using `which.max`-style index lookups.

### Data frames
- Building a data frame manually with `data.frame(col = c(...), ...)`.
- The `babynames` data set as a worked example.
- Row/column access by position (`df[2, 3]`), by name (`df[2, "name"]`), by ranges, and by column with `$`.
- `df$name` (a vector) vs `df["name"]` (a one-column data frame).
- Subsetting rows with a boolean mask built from column comparisons.
- Reading off the most common name in a year by combining a mask with `count == max(count)`.

### Function composition and the pipe
- Pure-math view of function composition: `g(f(x))`.
- The pipe operator `|>` and the keyboard shortcut Ctrl+Shift+M.
- Reading `x |> f() |> g()` as "take x, push through f, push through g".

### tidyverse data-frame verbs
- `filter` for rows; `select` for columns; `arrange` for sorting (and descending sort for "top" queries).
- `summarize` to build a new one-row data frame from aggregates.
- `group_by` + `summarize` for per-group aggregates (mean count per name by sex, etc.).
- `mutate` for adding a column (e.g. reconstructing total population from `n / prop`).
- `distinct` (row-level uniqueness) vs `unique` (vector-level).
- `rename`, and renaming inside `select`.
- `n()` inside `summarize` for row counts; `n_distinct` for distinct counts.
- `which.max` inside `summarize` after `group_by` to pull the row with the maximum.
- A worked end-to-end example: distinct names per capita per year on `babynames`.

### gapminder mini-tour
- The shape of the gapminder data: country / year / continent / lifeExp / pop / gdpPercap.
- Counting countries on a continent two ways (manual via `unique` + `length`; idiomatic via `filter` + `select` + `distinct` + `count`).
- A function that returns the country with the highest life expectancy on a continent within a year range.
- World population in a given year via `group_by(year) |> summarize(sum(pop))`.

### `sapply` and vector-safe functions
- Why `if` does not work on a vector; using `sapply(vec, fun = special_square)` to apply a non-vectorized function elementwise.
- `sapply` as the functional substitute for a `for` loop, and why it is the common idiom in R.

### Probability review
- Random variable vs event; capital vs lowercase notation (e.g. `X` vs `x`).
- Probability of a compound event ("no coin came up heads") and writing it carefully.
- Conditional probability via the formula definition.
- Independence: information about one variable does not change beliefs about the other.
- Bayes rule as the formula falling out of the definition of conditional probability.
- Law of total probability as a weighted sum of conditional probabilities.
- Worked examples with two coin tosses (`P(X1 + X2 = 2)`, conditional version).
- The boy-and-girl paradox (older child is a girl vs at least one is a boy).

---

## Lecture 2 — May 8

### Law of total probability, follow-up
- Re-stating the formula and combining it with Bayes' rule to compute posteriors over a discrete parameter.

### Maximum likelihood, on paper
- Setup: `n` iid Bernoulli(θ) tosses; data is `y_1, ..., y_n`.
- The single-trial likelihood written as `θ^y (1-θ)^(1-y)`.
- The data-set likelihood as the product over i; θ is a parameter, not a random variable — the conditional-probability notation is a convenient abuse.
- Maximizing the likelihood = maximizing the log-likelihood (monotonicity of log); log turns the product into a sum.
- Calculus derivation that `θ_MLE = (Σ y_i) / n` — the intuitive sample mean.

### Maximum likelihood, in code
- Generating data with `rbinom(n, size = 1, prob = θ)`.
- Implementing the per-point likelihood `θ^y (1-θ)^(1-y)`.
- Going from `prod(...)` to `exp(sum(log(...)))` for numerical stability with larger samples.
- Grid search over θ with `seq` + `sapply` + `which.max` — getting the MLE without calculus.
- Sample-to-sample variability of the estimate as a preview of confidence intervals.
- Boundary issue at θ = 1 (`log(0) = -Inf`); use a slightly smaller upper end.

### Maximum likelihood for linear regression
- The model: `y_i = θ^T x_i + ε_i`, `ε_i ~ N(0, σ^2)`.
- Per-point likelihood is the Gaussian density at `y_i - θ^T x_i`.
- Log-likelihood collapses to `-Σ (y_i - θ^T x_i)^2 / (2σ^2)` plus constants.
- Maximizing the log-likelihood ⇔ minimizing the sum of squared residuals; the OLS line is also the MLE under this noise model.
- Live coding: generating noisy data, plotting with `ggplot` + `geom_point`, computing log-likelihood on a grid.

### Bayesian inference, intuition
- Why "is the coin fair?" is, strictly, a bad question — replace it with "what is the posterior over θ?"
- Posterior ∝ likelihood × prior; `P(data)` as the normalizing constant from the law of total probability.
- Maximum likelihood vs maximum-a-posteriori vs full posterior.
- When the two diverge: outliers and the implicit Bayesian thinking ("throw away the outlier") that frequentist practitioners often do by hand.

### Bayesian inference, in code
- A grid of θ values and a prior built from `dnorm(θ - 0.5, sd = ...)`, normalized to a probability mass.
- Plotting the prior.
- Computing the unnormalized posterior at every θ as `likelihood × prior` (`P(data)` is the same for every θ and can be dropped for visualization).
- Plotting the resulting posterior and reading off the MAP.

---

## Lecture 3 — May 13

### Project requirements (preview)
- Unique data set (e.g. scraped from Reddit), at least one technique from the course, a dashboard artifact, and a "something extra".
- One-page proposal: data source plus a summary of ≥2 related papers; 1–2 people per project.
- Worked example: a published paper that scraped Reddit threads, used an LLM to find personal attacks, geolocated users, and tested whether US-South users retaliate more — illustrating the "scrape + statistical question + clean conclusion" shape of an ideal project.

### Frequentist hypothesis testing with finches
- Data set: Darwin's finch beak depths from 1976 (pre-drought) and 1978 (post-drought) on Daphne Major.
- First pass: `group_by(year) |> summarize(mean(Depth))` — the means differ slightly, but that alone proves nothing.
- Histograms with `ggplot` + `geom_histogram`: `fill = as.factor(year)`, `position = "stack"` vs `position = "dodge"`; why `as.factor` is needed when the column is numeric; `color` (outline) vs `fill` (interior).

### The null hypothesis and the p-value
- The null hypothesis: the means in 1976 and 1978 are equal.
- The p-value as `P(test statistic at least as extreme as observed | H_0 true)`.
- The convention p < 0.05 and why we say "reject" but never "accept" the null.
- Test statistics: difference of means, vs difference of means divided by an overall standard deviation (so the effect is in units of the data's spread).

### Computing the p-value by simulation
- Estimating the within-group standard deviation (and why the overall SD overestimates it when the means differ).
- `replicate(5000, ...)` to draw many `t` statistics under the null.
- Reading the p-value off a histogram of simulated `t`'s, or computing `mean(abs(replications) >= t_observed)`.
- One-sided vs two-sided test, and a contrived example (length of a chalk vs sum of two chalks) where one-sided is genuinely justified.

### Interpreting p-values, carefully
- 5% is an arbitrary historical convention; particle physics uses much smaller thresholds, social science struggles to reach 5% at all.
- ASA statement-style cautions: the p-value is not the probability the hypothesis is true; statistical significance is not effect size; do not report a p-value without context.
- Why "we are 95% sure H_0 is false" is wrong as a reading of `p = 0.05`.

### Errors
- Type I (reject when null is true) and Type II (fail to reject when null is false).
- Andrew Gelman's "I have never made a Type I or Type II error": if the null is essentially never literally true, the Type I framing isn't useful.
- Type S (sign) and Type M (magnitude) errors as a more honest framing of what actually goes wrong.

### Why most published findings might be false
- Publication bias / file-drawer effect.
- p-hacking and the "garden of forking paths" — choosing analyses after seeing the data.
- Pile-ups of reported p-values just under 0.05 as a fingerprint of the above.
- The dead-salmon fMRI study as a textbook multiple-comparisons cautionary tale.
- Remedies: replication, meta-analysis, pre-registration, having a theory before collecting data.

### Bayesian inference for difference of means
- Setting up the same finch problem as a posterior over `D = μ_2 − μ_1`.
- A flat prior on `D` for simplicity.
- Per-pair likelihood as the product of Gaussian densities (using `dnorm(..., log = TRUE)` and summing).
- Aggregating log-probabilities into one bucket per value of `D` across pairs of `(μ_1, μ_2)` consistent with that `D`.
- With a flat prior the MAP coincides with the MLE; tightening the prior pulls `D` toward zero.

---

## Lecture 4 — May 20

### Predictive modeling intro
- Notation: `m` training examples, `x` features/inputs, `y` targets/outputs.
- Housing-price example: drawing a line through the data and reading off a prediction.
- Two ways to motivate the squared cost: a direct business case for some loss function vs the Gaussian-noise generative story that makes squared error the MLE.
- Simple linear regression (one predictor) vs multiple linear regression (n predictors); the geometry of a hyperplane in higher dimensions.

### When a straight line is wrong
- gapminder: life expectancy vs GDP per capita is plainly not a straight line — but life expectancy vs `log(GDP per capita)` is.
- Transforming an axis to recover linearity before running regression.

### Categorical predictors
- Quantitative vs categorical variables; borderline cases (counts, colors, Likert scales).
- Indicator variables `I_{i,k}` and the "leave one category out" trick to avoid redundancy.
- Worked example with `lm(lifeExp ~ continent, data = ...)` on gapminder filtered to one year; the intercept is the held-out category's mean, the other coefficients are the offsets.
- Why the MLE for a categorical-only model with squared loss is the per-group mean.

### Titanic case study
- Predicting a binary outcome (survived = 0/1).
- Why plain linear regression is awkward here, and the sigmoid `σ(y) = 1 / (1 + e^{-y})` as a way to squash a real number into a probability.
- Logistic regression as the model `P(survived = 1) = σ(a_0 + a_1 x_1 + ...)`.
- `glm(survived ~ sex + age + Pclass, data = ..., family = binomial)` in R.
- Interpreting the coefficients on the Titanic fit (sex matters a lot; class matters; age basically does not).
- The logistic-regression cost function (negative log-likelihood / cross-entropy) sketched.

### Live workshop: scraping Reddit
- Using a coding agent inside VS Code to fetch posts via Arctic Shift.
- Asking the agent to write a Python script for top keywords; auditing what it actually does (e.g. silently removing stop words).
- A second prompt: "what fraction of posts in a boating subreddit mention drowning?" as a one-shot end-to-end example of agentic data work.

### ggplot for regression diagnostics
- `aes(x = log(gdpPercap), y = log(lifeExp))` for log-log plots; what is and isn't inside `aes`.
- `geom_point` + `geom_smooth(method = "lm")`; the default ribbon as a CI on the fit.
- Why log-transforming `y` doesn't always matter (life expectancy doesn't span enough orders of magnitude), but log-transforming `x` does.

### `predict()` and comparing models
- `predict(model, newdata = ...)` for fitted values on training or new data.
- Building a one-row `data.frame` to score a single new observation.
- Computing the sum of squared residuals by hand; why its absolute value alone is uninformative.
- Adding `year` as a second predictor and showing the SSE drop; reading the coefficient in conjunction with the typical year range.
- Note: the built-in `predict` handles categorical predictors automatically; you do not need to expand the indicators yourself.

### Evaluating logistic regression
- Thresholding predicted probabilities at 0.5 to get class predictions.
- Classification accuracy on the Titanic (~78.5%) and why that number means nothing without the base rate (~61% from "predict died every time").
- Comparing categorical vs continuous encodings of `Pclass`: in this data set they produce the same accuracy, but in principle they need not.
- Confusion-matrix language: false positive rate (FP / actual N), false negative rate (FN / actual P), positive predictive value (TP / predicted P), negative predictive value (TN / predicted N).
- Realistic example from hospital deterioration alerts: doctors mute high-FP systems, so FN dominates the design.

---

## Lecture 5 — May 22

### Mini-project 2 walkthrough — ICU adverse outcomes
- MIMIC-style ICU data: predicting mortality / palliative-care transfer from per-patient summary statistics.
- The historical context: a similar alert system was deployed in Ontario and the UK, but high false-positive rates trained staff to ignore the pages.
- The structure of the project: load the per-patient files, fit a logistic regression, plot an ROC curve, choose a threshold.
- The "doctor with 25 charts" cost model: time per chart → probability of missing the right intervention → expected deaths as a function of the alert threshold; the U-shaped curve and where its minimum sits.
- A sample exam-style question on this graph: come up with a reasonable criterion for choosing a threshold and justify it (midpoint, equal FPR/TPR weights, explicit cost ratio).

### Confidence intervals
- Definition: `estimate ± 2.5 × SE` for a 95% CI under the usual conditions.
- The interpretation: under repeated experiments, 95% of the constructed intervals contain the true parameter.
- What a CI is not: it is not the probability that the parameter lies in this particular interval — that probability is either 0 or 1 for a fixed parameter.
- Reading the CI off `summary(glm_fit)`: `Estimate` and `Std. Error` columns, the asterisks, and the p-value column.
- The duality: 0 lies in the 95% CI for a coefficient iff the p-value for "that coefficient is zero" exceeds 5%.
- Worked example on the Titanic glm: the coefficient on `sex` is far from zero (huge effect), the coefficient on `age` straddles zero (no evidence of an effect).

### Inference with linear regression
- The null hypothesis as a statement about a coefficient: typically `H_0: a_j = 0`.
- Why reading the p-value off `lm` output is dangerous without checking assumptions first: the formula always returns a number; that number is only a real p-value when the assumptions hold.
- Required assumptions: the conditional mean is linear in the predictors; residuals are normal around zero; residuals are independent.

### Diagnostic plots
- QQ plot of residuals vs a normal distribution; deviations from the straight line indicate heavier-than-normal tails or outliers.
- Residuals vs fitted values; clumping or systematic sign patterns indicate non-independence or non-linearity.
- Scale-location plot; if variability grows with fitted value, a log-transform of `y` may straighten things out (multiplicative error → additive on log scale).
- Residuals vs leverage; spotting individual high-influence observations.
- gapminder example with the outliers turning out to be resource-export economies (Sierra Leone, Angola, Gabon) — and the case for not just deleting them.

### Multiple comparisons in regression
- Reading many coefficient p-values is itself a multiple-comparisons problem.
- The F-test as a single test that "at least one coefficient is non-zero"; `summary(lm_fit)` reports it.
- Pre-registration vs exploratory reading of the table.

### Correlation ≠ causation
- Reverse causation, common cause, indirect causation, plain coincidence (pirates vs global temperature).
- Why a significant `a_1` is, by itself, never enough to claim "x causes y".

### R² and Anscombe's quartet
- R² as `1 - SSE_model / SSE_baseline`, where the baseline is "predict `mean(y)` every time".
- R² close to 1 ⇒ linear regression beats the constant predictor by a lot; R² close to 0 ⇒ it doesn't.
- Correlation `r` as the signed square root of R².
- Anscombe's quartet: four data sets with the same r but completely different shapes — visualize, don't trust one number.

### Cross-validation
- Why training-set accuracy lies: adding any variable cannot hurt training fit; encoding a numeric variable as categorical never hurts training fit (proof sketch: the categorical model can always reproduce the numeric one).
- Splitting indices into training, validation, and test via `sample(1:nrow(df))`.
- A helper that takes a fit and a data set and returns accuracy on that set.
- Using the validation set to choose between models, then a held-out test set for the chosen model.
- Using `replicate(1000, ...)` to repeatedly resample the validation set with the same trained model: a histogram of validation accuracies as a small-sample CI for performance.
- The trade-off in how to split: a larger validation set means a more reliable model choice but a smaller training set and smaller final test.

### "The truth about linear regression" (after Shalizi)
- Lie 1: a significant coefficient ⇒ the variable influences the response.
- Lie 2: an insignificant coefficient ⇒ the variable does not influence the response.
- Lie 3: changing `x_j` by 1 ⇒ the response changes by `a_j`.

### Collinearity
- Height and weight predicting GPA: when two predictors are highly correlated, `a_1` and `a_2` are almost arbitrary as long as their combination is right; you cannot interpret either alone.
- Remedies: drop a redundant variable, or use a dimensionality-reduction technique (with its own caveats).

### Omitted-variable bias
- Childhood-nutrition story for height/weight vs GPA.
- Ice cream and drownings as the canonical "lurking variable is the weather" example.
- Adding the lurking variable as a predictor when you can identify it.
- Fisher and smoking as a historical illustration of how the "common cause" argument can be misused.

### What to control for: interpretation problems
- The gender wage gap: controlling for childbirth vs field of employment changes the headline coefficient; the choice is partly a question about what causal claim you want to make, not a purely statistical decision.
- The Harvard admissions lawsuit as another example where competent statisticians honestly disagree about which controls to include.

### Errors in variables
- Imprecise measurement of an input variable biases its coefficient toward zero (pure noise gets multiplied by zero in the best fit).
- Very large sample sizes make every coefficient "significant", which is yet another reason a small p-value alone is not the same as a meaningful effect.

### Interactions
- Avocado / bacon example: adding avocado has a different effect depending on whether bacon is present, so the additive model `a_0 + a_1 I_av + a_2 I_bac` cannot fit.
- Adding the product term `a_{12} I_av I_bac` recovers the four observed cell values; solving for the coefficients algebraically.
- When to add an interaction in practice: only when there's a theoretical reason to expect the effect of one predictor to depend on another, then test whether `a_{12} = 0`.
