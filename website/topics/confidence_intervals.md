---
title: "Confidence Intervals"
output:
  html_document: default
  pdf_document: default
---



This is the other thing where there are YouTube videos at scientific conferences where they ask people what a confidence interval is and nobody knows the answer. Let's try to do it.

## The definition

Suppose we have the finches data and we want the difference between the means in 1976 and 1978. We compute it from our sample:

$$\hat D = \bar d_{1978} - \bar d_{1976}.$$

For our actual data this is some number — say 0.4 (rough). We can also compute a **95% confidence interval**:

$$\hat D \pm \text{margin of error}.$$

A 95% CI written as $0.4 \pm 0.3$ (so $[0.1, 0.7]$) means the following:

> If we repeat the same experiment many times (hatch a bunch of finches in 1976 and 1978, measure their beaks, compute the sample-mean difference, and re-construct the CI from each new sample), then in 95% of those repeated experiments, the **true** difference between the population means will fall inside the constructed CI.

So it is a conditional, and it is a conditional about a hypothetical about repeating the experiment.

## What a CI is *not*

A very common mis-reading is "the true answer is in $0.4 \pm 0.3$ with probability 95%."

It is not. The true difference is some fixed number $D$ — a property of the populations. There is no randomness in $D$. For a specific interval $[0.1, 0.7]$, either $D \in [0.1, 0.7]$ (in which case the probability is 1) or $D \notin [0.1, 0.7]$ (probability 0). You just don't know which.

The confidence interval is a way of putting a reasonable interpretation of probability into the picture, but the probability is over the *procedure* of computing the interval, not over $D$ itself. The repetition of the experiment doesn't change the value you actually estimate — it says "I'm constructing an interval such that if I were to repeat the experiment, 95% of those intervals would contain the true value."

## In practice

Does any of this matter? It kind of matters if you care about saying the correct thing, and it matters if you care about saying the correct thing at a data-science interview. This is the kind of thing people ask.

In practice, most people just treat the CI you obtain as "the answer is probably somewhere in there." Technically that is wrong, but kind of close enough.

Part of the philosophical difference is that there is just no way to estimate the probability of where the true parameter is **without incorporating prior beliefs about where it might be**. The CI you compute here is the **frequentist confidence interval**. To make a probability statement about $D$ itself, you need a prior — that is the Bayesian topic.

## Reading CIs off `glm` / `lm` output

Let's fit logistic regression on the Titanic:


``` r
library(titanic)
train <- titanic_train
fit <- glm(Survived ~ Sex + Age, data = train, family = binomial)
summary(fit)
```

```
## 
## Call:
## glm(formula = Survived ~ Sex + Age, family = binomial, data = train)
## 
## Coefficients:
##              Estimate Std. Error z value Pr(>|z|)    
## (Intercept)  1.277273   0.230169   5.549 2.87e-08 ***
## Sexmale     -2.465920   0.185384 -13.302  < 2e-16 ***
## Age         -0.005426   0.006310  -0.860     0.39    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 964.52  on 713  degrees of freedom
## Residual deviance: 749.96  on 711  degrees of freedom
##   (177 observations deleted due to missingness)
## AIC: 755.96
## 
## Number of Fisher Scoring iterations: 4
```

The summary table has a column called `Std. Error`. The 95% CI for each coefficient is approximately:

$$\text{Estimate} \pm 2.5 \cdot \text{SE}.$$

(More precisely, $\pm 1.96 \cdot \text{SE}$; using 2.5 is the version you can keep in your head.)

For the intercept, that's $0.78 \pm 2.5 \cdot 0.23$. The interpretation: if we compute the CI for 100 different samples, in 95 of them the true value of the intercept will be in the constructed CI.

Loosely, you say "what's the intercept? Well, something like this."

## CI ⇔ p-value for $\beta = 0$

There is a built-in test for whether the value of a coefficient is zero or not:

> If 0 is in the 95% CI, then the p-value for the null hypothesis "this coefficient = 0" is greater than 5%.

That kind of makes sense: if your confidence interval contains zero, then loosely speaking the data is consistent with zero. (There is a math trick that makes this not a formal entailment, but it is the intuition.)

The `summary()` table also reports the p-value for "this coefficient is zero" — that is the `Pr(>|z|)` (or `Pr(>|t|)` for `lm`) column.

You'll notice the intercept's p-value is extremely small. The asterisks `***` indicate very small p-values. But that is not an interesting fact for the intercept — the hypothesis "the intercept in the formula is zero" is one nobody actually cares about.

The interesting coefficients are the predictors. From the Titanic fit:

- **`Sexmale` coefficient** is about $-0.55$ with SE $0.07$. Plus or minus $2.5 \cdot 0.07 \approx 0.175$ — that's $[-0.72, -0.38]$. Zero is **not** in this interval, so the p-value is small. That corresponds to "according to the model, sex actually matters."
- **`Age` coefficient** is about $-0.00009$ with SE around $0.005$. The 95% CI covers zero, so the p-value is larger than 5%. According to the model, you don't even know whether age has a positive or negative effect on probability of survival — basically you have no evidence about it from this data.

That is the standard "is sex significant? Yes. Is age significant? No, on this data with this model."

## Summary

- A confidence interval is a probability statement about the *procedure*, not about the parameter. The parameter is fixed; the interval is random.
- 95% means: 95 of every 100 such intervals you'd construct from repeated samples will contain the true value.
- In practice most people just read it as "the answer is probably in here." That is technically wrong but useful.
- 0 in the 95% CI ⇔ p-value for $\beta = 0$ exceeds 0.05.
