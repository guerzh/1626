---
title: "Causal Inference"
output:
  html_document: default
  pdf_document: default
---



## "Correlation does not imply causation"

You hear this from age 12. It's true, but it doesn't tell you what to do. The point of this lecture: there is a real, formal sense in which we can sometimes recover causal effects from observational data — and a real, formal sense in which we usually can't, no matter how big the dataset.

> "I used to think correlation implied causation. Then I took a statistics class. Now I don't." — Sounds like the class helped. — "Well, maybe."
> *[xkcd 552]*

## What "A causes B" actually means

The cleanest working definition (the **counterfactual** one):

> $A$ caused $B$ if $B$ would not have happened had $A$ not happened.

This is intuitive, but it's hard to apply: we never observe both worlds. For any given person who smoked and got cancer, we don't see the version where they didn't smoke. **Causal inference** is the project of extracting counterfactual statements from data we *can* see.

This lecture follows the framework that's now standard in the field: causal models live on a directed acyclic graph (DAG), and the formal object we want is $P(Y \mid \mathrm{do}(X = x))$, distinct from $P(Y \mid X = x)$.

## DAGs as a language for causal structure

A **directed acyclic graph (DAG)** is a picture of how the variables in a system generate each other. Each node is a variable. Each arrow $A \to B$ means "$A$ is one of the things that determines $B$" — i.e., $A$ enters into the mechanism that generates $B$.

The canonical Shalizi example:

```
Smoking ──► Yellow teeth
   │
   └──► Tar in lungs ──┐
                       ├──► Cancer
       Asbestos ───────┘
```

Reading this graph as a generative recipe:

1. Generate `Smoking` (0 or 1) from some marginal distribution.
2. Generate `Asbestos` from its own marginal distribution, independently of `Smoking`.
3. Generate `Yellow teeth` and `Tar in lungs` from `Smoking`.
4. Generate `Cancer` from `Tar in lungs` and `Asbestos`.

The graph encodes our **assumptions** about the data-generating process. Different DAGs make different predictions about which variables are (conditionally) independent.

**Caveat.** An arrow $A \to B$ does not mean $A$ always causes $B$ on every instance — it means the mechanism that generates $B$ takes $A$ as an input. A drawn arrow says "$A$ *might* affect $B$"; the absence of an arrow says "$A$ definitely doesn't (directly) affect $B$." Absences carry more force than presences.

## Independence relations from the graph

Three patterns are worth memorising:

**1. Common cause.** `Yellow teeth ← Smoking → Tar in lungs`. Yellow teeth and Tar are *not* independent (smokers tend to have both), but they are independent **conditional on Smoking**. If you already know whether someone smoked, knowing their teeth tells you nothing extra about their lungs. Conditioning on a confounder *blocks* the path.

**2. Chain.** `Smoking → Tar → Cancer`. Smoking and Cancer are not independent, but they are independent given Tar (if the only way smoking causes cancer is via tar — strong assumption, but the point is structural).

**3. Collider — "explaining away".** `Tar → Cancer ← Asbestos`. Marginally, Tar and Asbestos are *independent* (one is caused by smoking; the other isn't). But **conditional on Cancer**, they become *dependent*: if someone has cancer and we learn they were exposed to asbestos, that "explains" the cancer, lowering the probability they also had tar buildup. Conditioning on a collider *opens* a path that was closed.

These rules together are called **d-separation**, and they're the link between a DAG's structure and the conditional-independence statements you can read off it.

### Let's see it in code


``` r
set.seed(1)
n <- 50000

smoking  <- rbinom(n, 1, 0.3)
asbestos <- rbinom(n, 1, 0.1)   # independent of smoking

tar      <- rbinom(n, 1, ifelse(smoking == 1, 0.85, 0.05))
yellow   <- rbinom(n, 1, ifelse(smoking == 1, 0.60, 0.05))

p_cancer <- pmin(0.02 + 0.30 * tar + 0.50 * asbestos, 0.95)
cancer   <- rbinom(n, 1, p_cancer)

df <- data.frame(smoking, asbestos, tar, yellow, cancer)
```

Check the three patterns:


``` r
# 1. Common cause: yellow and tar are marginally dependent (both caused by smoking).
cor(df$yellow, df$tar)
```

```
## [1] 0.4993546
```

``` r
# But independent given smoking:
cor(df$yellow[df$smoking == 1], df$tar[df$smoking == 1])
```

```
## [1] -0.002611089
```

``` r
cor(df$yellow[df$smoking == 0], df$tar[df$smoking == 0])
```

```
## [1] -0.002311224
```

Marginally correlated ($\approx 0.45$); within strata of `smoking`, the correlation vanishes.


``` r
# 3. Collider: tar and asbestos are marginally independent.
cor(df$tar, df$asbestos)
```

```
## [1] -0.002658525
```

``` r
# But dependent conditional on cancer:
cor(df$tar[df$cancer == 1], df$asbestos[df$cancer == 1])
```

```
## [1] -0.5038938
```

Marginally near zero, conditionally **negative**. This is "explaining away" in action: among cancer patients, learning that someone was exposed to asbestos *reduces* the probability they had tar buildup, because the asbestos already accounts for their cancer.

The conditional dependence is a graphical fact, not a quirk of the simulation parameters. It would hold for any data generated by this DAG.

## The trap: regressing on the wrong variables

What is the causal effect of **asbestos** on **yellow teeth**?

By construction: zero. There is no path in the DAG from `Asbestos` to `Yellow teeth`. They're causally unrelated.

A naïve analyst might run


``` r
summary(lm(yellow ~ asbestos + cancer, data = df))$coefficients
```

```
##               Estimate  Std. Error   t value     Pr(>|t|)
## (Intercept)  0.1876197 0.001984288  94.55264 0.000000e+00
## asbestos    -0.1376235 0.006571463 -20.94260 5.727435e-97
## cancer       0.2634974 0.005386273  48.92017 0.000000e+00
```

and find a "significant" coefficient on `asbestos` — because conditioning on `cancer` opens up the collider path. The coefficient is real (the conditional association is real), but it has no causal interpretation. "Adjusting for cancer" was exactly the wrong move.

The correct regression for the causal question "does asbestos affect yellow teeth?" is


``` r
summary(lm(yellow ~ asbestos, data = df))$coefficients
```

```
##                 Estimate  Std. Error     t value  Pr(>|t|)
## (Intercept)  0.216416252 0.001939769 111.5680539 0.0000000
## asbestos    -0.005154271 0.006129187  -0.8409388 0.4003862
```

The coefficient on `asbestos` is essentially zero. Good — that matches the truth in the DAG.

**This is the entire reason DAGs matter in practice.** "Just throw everything into the regression" is not a safe default. Whether you should condition on a variable depends on its role in the causal graph: confounders should usually be in the regression; colliders and descendants of the treatment should usually be left out.

## $P(Y \mid X = x)$ vs. $P(Y \mid \mathrm{do}(X = x))$

This is the heart of the matter. There are two very different questions you might ask:

- **Observational**: $P(Y \mid X = x)$ — "Among people whose $X$ happens to be $x$, what's the distribution of $Y$?"
- **Interventional**: $P(Y \mid \mathrm{do}(X = x))$ — "If we *forced* $X$ to be $x$ (severing whatever normally determines $X$), what's the distribution of $Y$?"

The first is just conditioning on observed data. The second is asking about a hypothetical experiment.

These two are not equal in general. They're only equal when $X$ doesn't share a cause with $Y$ — i.e., when conditioning on $X$ behaves the same as physically setting $X$.

### Simulating the do-operator

The cleanest way to internalize $\mathrm{do}$ is to simulate from the modified graph. Setting $\mathrm{do}(\text{Asbestos} = 1)$ means: re-run the data-generating process, but always force `Asbestos` to 1, ignoring its usual marginal distribution.


``` r
intervene_asbestos <- function(n, asbestos_value){
  smoking  <- rbinom(n, 1, 0.3)
  asbestos <- rep(asbestos_value, n)               # forced
  tar      <- rbinom(n, 1, ifelse(smoking == 1, 0.85, 0.05))
  yellow   <- rbinom(n, 1, ifelse(smoking == 1, 0.60, 0.05))
  p_cancer <- pmin(0.02 + 0.30 * tar + 0.50 * asbestos, 0.95)
  cancer   <- rbinom(n, 1, p_cancer)
  data.frame(smoking, asbestos, tar, yellow, cancer)
}

df_do1 <- intervene_asbestos(50000, 1)
df_do0 <- intervene_asbestos(50000, 0)

mean(df_do1$yellow)
```

```
## [1] 0.21428
```

``` r
mean(df_do0$yellow)
```

```
## [1] 0.21334
```

These two means are essentially identical: $\mathrm{do}(\text{Asbestos} = 1)$ and $\mathrm{do}(\text{Asbestos} = 0)$ produce the same distribution of yellow teeth, because asbestos has no causal path to yellow teeth in the DAG.

That's the "no causal effect" claim formalised.

Meanwhile, the conditional probability among people who happened to have asbestos exposure *and* cancer was different from the marginal — that's the observational `lm(yellow ~ asbestos + cancer)` finding from earlier. The two statements are not in conflict: one is about the joint distribution of observables; the other is about an intervention. They're answering different questions.

## Identifying causal effects from observational data

The next question: when we don't have the luxury of a randomised experiment (the actual gold standard for computing $P(Y \mid \mathrm{do}(X))$), can we recover causal effects from observational data alone?

The answer is **sometimes**, and three classical strategies cover most of practice.

### Strategy 1: regression with the right controls (backdoor adjustment)

If we have the DAG and observe enough variables, there's a formal recipe (the **backdoor criterion**) for which set of variables we should condition on to make a regression coefficient have a causal interpretation. The rough rule:

- **Do** control for variables on paths between $X$ and $Y$ that go *backwards* into $X$ (confounders).
- **Don't** control for descendants of $X$, or for colliders that aren't on any backdoor path.

This is the move that turns "$X$ is associated with $Y$ controlling for $Z$" into "$X$ causes $Y$." But it requires the DAG: there's no algorithm that picks the right controls from the data alone.

### Strategy 2: instrumental variables

Suppose you want the effect of `Smoking` on `Health`, and you suspect there are unmeasured confounders (people who smoke might also live unhealthier lives in ways you can't observe). An **instrument** $I$ is a variable that:

1. affects `Smoking`,
2. has no direct effect on `Health` except through `Smoking`, and
3. is not confounded with `Health`.

`Cigarette tax` is a candidate: it changes with state and over time, drives smoking rates, and arguably doesn't affect health except through smoking.

```
Tax  ───►  Smoking  ───►  Health
```

If those three conditions hold, you can read off the causal effect of `Smoking → Health` from the relationship between `Tax` and `Health`, even with unmeasured confounders on the smoking↔health link. This is a strong assumption — instrument-validity arguments are usually the hardest part of an IV paper.

### Strategy 3: matching

For each treated unit (e.g., a person who smoked), find an untreated unit that looks the same on every measured covariate. Compare them. Repeat. The estimated effect is the average of the within-pair differences.

The hope: if you've matched on every confounder, the matched pairs differ only on the treatment, so you've recovered the counterfactual. The catch: you have to actually have measured the confounders, and you have to pair on all of them. **Propensity score matching** is the most common automated version.

## A bigger DAG: brushing and heart disease

A motivating worry: people who brush their teeth a lot also tend to exercise more, eat better, and so on, because they share a latent trait ("conscientiousness" / health-consciousness). A naïve regression of `Heart Disease ~ Brushing` will say brushing prevents heart disease — but the effect could be entirely driven by the confounder.

The DAG (Shalizi, Ch. 22):

```
        Health-consciousness ──────────────┐
            │                              │
            ▼                              ▼
  Brushing ──► Gum disease ──► Inflammation ──► Heart disease
            │                                          ▲
            │  Exercise ──► (fat in diet) ─────────────┘
            ▼
       (paths via the dental side)
```

To estimate the causal effect of brushing on heart disease, you'd need to either (a) observe and condition on health-consciousness (impossible — it's latent), (b) find an instrument that shifts brushing without affecting heart disease through any other channel (also hard), or (c) run an experiment where brushing is randomized (ethically and logistically dubious).

This is the honest reason most observational claims about lifestyle and chronic disease are heavily caveated. The DAG forces you to be explicit about the assumptions that would make a causal claim defensible — and often, *no* assumption available to you is defensible.

## Summary

- $P(Y \mid X = x)$ and $P(Y \mid \mathrm{do}(X = x))$ are different objects. Standard statistics gives you the first; causal inference is the project of getting to the second.
- A causal effect is identifiable from observational data only under structural assumptions, usually encoded as a DAG.
- The three practical strategies for observational causal inference are: regression with the right controls (backdoor adjustment), instrumental variables, and matching. All require assumptions the data alone cannot verify.
- When in doubt, the safe statement is "$X$ is *associated* with $Y$." That's a claim about $P(Y \mid X)$, and you don't need a causal model to back it up.

## References

- Shalizi, *Advanced Data Analysis from an Elementary Point of View*, Ch. 21–24 — the source of the smoking/asbestos DAG and the framework above.
- Pearl, *Causality* (2009) — the canonical formal treatment of $\mathrm{do}$ and identification.
- Pearl, Glymour & Jewell, *Causal Inference in Statistics: A Primer* — a more accessible introduction.
- Hernán & Robins, *Causal Inference: What If* — the standard reference for epidemiology and the potential-outcomes framework.
