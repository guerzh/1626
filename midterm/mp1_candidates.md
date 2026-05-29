# MP1-style candidates (tidyverse · probability · MLE · Bayesian · low p-values)

Modelled on Mini-Project 1: dplyr wrangling on `babynames`, Bayesian inference (MAP, effect of prior and sample size), and "low p-values don't imply an important association." Datasets are kept small/abstract so they can be done on paper.

---

### Q1 — Totals and proportions with dplyr (8 pts)

A data frame `sales` has columns `year`, `product`, `units`. Write dplyr code to compute, **for each year**, (a) the total units sold, and (b) the proportion of that year's units that were the product `"Widget"`.

*Answer.* 
```r
sales %>% group_by(year) %>%
  summarize(total = sum(units),
            widget_prop = sum(units[product == "Widget"]) / sum(units))
```
Full marks for any correct `group_by` + `summarize` that produces a per-year total and a within-year proportion. A `filter`-then-join is also acceptable.

---

### Q2 — Most popular per group (8 pts)

`babynames` has columns `year, sex, name, n`. Write code that returns, for each year, the single name with the largest `n` (ignoring sex). Then say what one change makes it return the **top 3** per year.

*Answer.*
```r
babynames %>% group_by(year) %>% summarize(top = name[which.max(n)])
```
Top 3: `group_by(year) %>% arrange(desc(n)) %>% slice(1:3)` (or `slice_max(n, n = 3)`). Marking: `which.max` for the single-name case; correct grouped `arrange`+`slice` for top-3.

---

### Q3 — Read a pipeline (6 pts)

State the columns and a couple of representative rows of the data frame produced by:
```r
babynames %>%
  filter(sex == "F") %>%
  group_by(year) %>%
  summarize(distinct_names = n_distinct(name),
            babies = sum(n)) %>%
  mutate(names_per_1000 = 1000 * distinct_names / babies) %>%
  arrange(desc(names_per_1000))
```
*Answer.* One row per year (girls only), columns `year, distinct_names, babies, names_per_1000`, sorted from the year with the most distinct girls' names per 1000 girls down. Full marks for correct schema + that it's sorted descending on the derived ratio. Tests whether they can trace `group_by → summarize → mutate → arrange`, not memorize verbs.

---

### Q4 — MLE for a coin, on paper then by grid search (10 pts)

A coin with $P(\text{heads}) = p$ is flipped $n$ times and comes up heads $k$ times. (a) Derive the maximum-likelihood estimate $\hat p$. (b) Write R that finds $\hat p$ numerically by evaluating the (log-)likelihood on a grid `p_grid <- seq(0, 1, 0.001)` and taking the best point.

*Answer.* (a) Likelihood $\propto p^k (1-p)^{n-k}$; set derivative of $\log$ to 0 ⇒ $\hat p = k/n$. (b)
```r
p_grid <- seq(0, 1, 0.001)
loglik <- k * log(p_grid) + (n - k) * log(1 - p_grid)
p_grid[which.max(loglik)]
```
Marking: 5 for the derivation reaching $k/n$; 5 for a grid + `which.max` (log or raw likelihood both fine).

---

### Q5 — How sample size sharpens the MAP estimate (10 pts)

With a **uniform** prior on $p$ and true $p = 0.4$, you simulate 1000 datasets of $n$ flips each and record the MAP estimate of $p$ for each. Describe how the **histogram of MAP estimates** changes as $n$ goes from 100 to 500 to 2000, and write the simulation for one value of `n`.

*Answer.* The histogram stays centred near 0.4 but gets **narrower** as $n$ grows (estimates concentrate; variance $\propto 1/n$). With a uniform prior the MAP equals the MLE $k/n$.
```r
maps <- replicate(1000, {
  k <- rbinom(1, size = n, prob = 0.4)
  k / n                       # MAP = MLE under a uniform prior
})
hist(maps)
```
Marking: "narrows / concentrates around 0.4 as n grows" + a correct `replicate` over `rbinom`.

---

### Q6 — When the prior dominates (10 pts)

You observe $k = 3$ heads in $n = 10$ flips. You use a prior that is strongly concentrated near $p = 0.5$ (you may take prior weights `w(p)` as given on a grid). Write R to compute the **posterior on a grid** and report the MAP. Then say, in one sentence, when the posterior MAP will sit close to $0.5$ rather than close to the MLE $0.3$.

*Answer.*
```r
p_grid    <- seq(0, 1, 0.001)
prior     <- w(p_grid)                                   # given
lik       <- p_grid^3 * (1 - p_grid)^7
post      <- prior * lik
post      <- post / sum(post)                            # normalize
p_grid[which.max(post)]
```
The MAP stays near 0.5 when the prior is sharp **and** the data are few ($n$ small): little data can't overcome a confident prior. As $n$ grows the likelihood dominates and the MAP moves toward $k/n$. Marking: prior × likelihood, normalization, `which.max`; correct intuition.

---

### Q7 — Posterior arithmetic on a tiny grid (8 pts)

Prior on $p$ is uniform over the three values $\{0.2, 0.5, 0.8\}$. You flip once and get **heads**. Compute the posterior probability of each value.

*Answer.* Likelihood of heads = $p$. Unnormalized: $0.2, 0.5, 0.8$ (each ×1/3, but the 1/3 cancels). Normalize by $0.2+0.5+0.8 = 1.5$: posterior $= (0.133,\ 0.333,\ 0.533)$. Marking: likelihood = $p$, multiply by (equal) prior, divide by the sum.

---

### Q8 — Big $n$ makes tiny effects "significant" (12 pts)

This is the punchline of MP1 Part 3. Explain in 2–3 sentences why, when you generate data from $Y = a_0 + a_1 X + \varepsilon$ with a **very small** $a_1$, you will *almost always* reject $H_0: a_1 = 0$ once $n$ is large. Then write a simulation that estimates the rejection rate at a given $n$.

*Answer.* The standard error of $\hat a_1$ shrinks like $1/\sqrt{n}$, so for any nonzero $a_1$ the test statistic $\hat a_1/\mathrm{SE}$ grows without bound and the p-value $\to 0$ — significance reflects *sample size*, not effect size.
```r
reject <- replicate(500, {
  x <- rnorm(n); y <- 0 + 0.02 * x + rnorm(n, sd = 1)
  summary(lm(y ~ x))$coefficients["x", "Pr(>|t|)"] < 0.05
})
mean(reject)                 # rises toward 1 as n grows
```
Marking: the SE-shrinks-with-n argument + a `replicate` that fits `lm` and checks the p-value.

---

### Q9 — Significance vs. importance (8 pts)

A regression on $n = 200{,}000$ rows reports slope $\hat a_1 = 0.013$, $p < 10^{-6}$, $R^2 = 0.0008$. A colleague concludes "$X$ is an important driver of $Y$." Respond.

*Answer.* The tiny p-value only says $a_1$ is reliably **nonzero**, not large; $R^2 \approx 0.0008$ means $X$ explains essentially none of the variation in $Y$. With huge $n$, trivial effects are significant. Statistical significance ≠ practical importance. Marking: separate "significant" from "important"; cite the near-zero $R^2$ and the role of large $n$.

---

### Q10 — Proportions and the year of peak popularity (8 pts)

Using `babynames(year, sex, name, n)`, write code to compute the **proportion** of all babies each year that were given the name `"Emma"`, and then return the single year in which that proportion was highest.

*Answer.*
```r
emma <- babynames %>% group_by(year) %>%
  summarize(emma_prop = sum(n[name == "Emma"]) / sum(n))
emma$year[which.max(emma$emma_prop)]
```
Marking: per-year proportion (Emma's count over total that year) + `which.max` on the proportion. Accept a `filter`+join variant.
