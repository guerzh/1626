---
title: 'The Truth About Linear Regression: Collinearity, Omitted Variables, Interactions'
output:
  html_document: default
  pdf_document: default
---



This topic is built around a deck called "The Truth About Linear Regression" — material based on Cosma Shalizi's textbook (which is free online if you are interested).

There's an XKCD comic that captures the spirit: "I used to think correlation implied causation. Then I took a statistics class. Now I don't." "Sounds like the class helped." "Well, maybe."

So here is Shalizi's framing. These are **lies about linear regression** — things people commonly believe that aren't true.

## Lie 1. "A variable has a significant regression coefficient, so it must influence the response."

Not necessarily. That is correlation/causation. Discussed in detail in the correlation-vs-causation topic.

## Lie 2. "A variable has an insignificant regression coefficient, so it doesn't influence the response."

Also not necessarily. We will see this with collinearity below, and with errors in variables.

## Lie 3. "If the input variable changes by 1, we can predict the change in the response by plugging it into the regression."

Also not always true. Again, collinearity is one mechanism.

## Collinearity

Suppose you have two predictor variables: someone's weight and someone's height. We are predicting GPA:

$$\widehat{\text{GPA}} = a_0 + a_1 \cdot \text{height} + a_2 \cdot \text{weight}.$$

Weight and height are correlated — taller people tend to weigh more, and vice versa. Now we estimate $a_1$ and $a_2$.

The problem: if height and weight are highly correlated, $a_1$ and $a_2$ are basically not going to tell you much. You can push $a_1$ up and $a_2$ down (or the other way), and the prediction is going to be kind of the same, because weight and height are essentially the same variable on different scales.

So the value of $a_1$ doesn't really tell you about how GPA is related to height. There is no unique answer — there is a trade-off between $a_1$ and $a_2$.

As a result, you cannot say:

> "Increase the height by 1 cm and GPA rises by $a_1$."

Even if $a_1$ happens to be, say, 0.1. The reason: $a_1$ could be lower, $a_2$ could be higher, and the data would still be fit.

### Solutions

- **Remove redundant variables.** Weight and height both measure "the size of a person"; just use one. Sometimes solves the issue, but can be dangerous: they might not be perfectly correlated, so dropping one throws information away.
- **PCA and related dimensionality-reduction techniques.** Combine correlated variables into one or two principal components. Also has its own problems (the components are not interpretable as "height" or "weight" anymore).

## Omitted-variable bias

You are trying to predict GPA from height and weight. You see that $a_1 > 0$ and $a_2 > 0$. You might be tempted to say height and weight are positively associated with GPA in some interesting way.

But there might be a **lurking variable** that is the actual cause. For example, **early-childhood nutrition.** Good nutrition → you grow taller and have appropriate weight; also good nutrition → better cognitive development → higher GPA. There is no direct effect of height or weight on GPA — both height-and-weight and GPA are downstream of nutrition.

### The canonical example: ice cream and drownings

People often say that the amount of ice cream consumed in a day is correlated with the number of drownings in that day. This is **true**.

The lurking variable: **the weather**. Nice weather → people go to the beach → more ice cream eaten AND more swimming → more drownings.

If you actually want a model, you can include the weather as a predictor. Then conditional on the weather, the spurious correlation between ice cream and drownings disappears.

### Fisher and smoking

Ronald Fisher — same Fisher as in "fishers exact test" and frequentist statistics in general — was famously unconvinced to his final days that smoking causes lung cancer. He said that yes, smoking and lung cancer are correlated, but: maybe **genetics** causes some people to both smoke and have lung cancer. Or maybe people who are getting ill (independently) feel sad and want to smoke. Common-cause arguments.

He was probably wrong. (There are also claims he was paid by tobacco companies; I don't know.) But the structure of the argument is logically valid — for any correlation, there is always the possibility of a common cause.

## What to control for: the gender wage gap

It is widely reported that there is a wage gap between men and women. If you just regress:

$$\text{wage} = a_0 + a_1 \cdot I_{\text{male}}$$

$a_1$ comes out significantly positive — men, on average, have higher wages, in Canada and the US and many countries.

Now you ask: are there lurking variables? And do you want to include them?

### Add `gave_birth`

$$\text{wage} = a_0 + a_1 \cdot I_{\text{male}} + a_2 \cdot I_{\text{gave\_birth}}.$$

What happens: $a_2$ becomes negative and $a_1$ becomes much smaller. Women who don't give birth have wages very close to male wages. The story: giving birth → child-care responsibilities → maternity leave → career suffers → lower wages.

The question becomes: which model is "right"? Is the original gender wage gap explained "by" having given birth?

- One reading: the causal mechanism is real (no one disputes that child-care responsibilities affect wages), so we should control for it.
- Another reading: society is structured in a way that makes that happen. There is insufficient compensation for parental leave (and especially maternal leave). The "real" cause is structural.

### Add `field_of_employment`

If you add field of employment, a lot of the remaining gap gets attributed to field choice. Female-dominated fields historically have lower wages.

- One reading: people just choose to go into different fields; no gap once you control for it.
- Another reading: society is structured such that female-dominated fields get paid less on average.

This is more a matter of **interpretation** than of math. Math tells you what the coefficients are; it doesn't tell you what the causal structure is, and even less how to interpret it. You could control for the *name* of every individual and have zero gap — which would obviously be meaningless.

### Harvard admissions lawsuit

Another example, more recent: there was a US Supreme Court lawsuit against Harvard alleging that Asian applicants had better grades but lower interview scores, and consequently needed higher grades for the same admission probability. The counter: the interview score is measuring a real thing.

If you read the statistician briefs for both sides, you have highly qualified people arguing for completely different interpretations — and that kind of indicates that statistics alone is not enough to decide, because you can use statistics to "prove" basically whatever, depending on what you control for.

## Errors in variables

Input variables are measured imperfectly. For example, family income — you never know the family income; you know what the family says on a survey, which is probably inaccurate.

Imprecise measurement of an input tends to make its coefficient **smaller in magnitude** (toward zero). Intuition: imagine the input is pure noise (measured infinitely imprecisely). Then the only thing the model can do is multiply it by zero and ignore it.

## Large sample size makes everything "significant"

If your sample size is large enough, all the coefficients are going to be significant — you can reject zero for everything — just because your standard errors get tiny.

Even a coefficient of 0.000001 can be statistically significant if you have a billion rows. But the effect size is meaningless.

## Interactions

There is one more important pattern: the effect of one variable depends on the value of another. We add an **interaction term**.

### The avocado / bacon example

(The lecturer is vegetarian, but the example is illustrative.)

The data:

```
| avocado | bacon | deliciousness |
|---------|-------|---------------|
|   no    |  no   |     1         |
|   no    | yes   |     3         |
|  yes    |  no   |     3         |
|  yes    | yes   |     9         |
```

The claim: adding avocado has a different effect depending on whether the sandwich has bacon.

- No bacon: avocado adds $3 - 1 = 2$.
- With bacon: avocado adds $9 - 3 = 6$.

### Why a plain additive model can't fit

Our initial model:

$$\text{deliciousness} = a_0 + a_1 \cdot I_{\text{avocado}} + a_2 \cdot I_{\text{bacon}}.$$

From this, **every time you add avocado, you add $a_1$ to deliciousness, no matter what.** That's the whole point of an additive model. So this formula can never reproduce the data (2 vs 6 for adding avocado).

### Adding the interaction term

Add a third term:

$$\text{deliciousness} = a_0 + a_1 \cdot I_{\text{avocado}} + a_2 \cdot I_{\text{bacon}} + a_{12} \cdot I_{\text{avocado}} \cdot I_{\text{bacon}}.$$

The product term is 1 only when both `avocado` and `bacon` are 1.

Solve for the coefficients from the four data points:

- No avocado, no bacon: $a_0 = 1$.
- No avocado, bacon: $a_0 + a_2 = 3 \Rightarrow a_2 = 2$.
- Avocado, no bacon: $a_0 + a_1 = 3 \Rightarrow a_1 = 2$.
- Avocado, bacon: $a_0 + a_1 + a_2 + a_{12} = 9 \Rightarrow 1 + 2 + 2 + a_{12} = 9 \Rightarrow a_{12} = 4$.

So the interaction coefficient is $a_{12} = 4$, and the model fits the data exactly.

### General principle

If the effect of $x_1$ on $y$ is different depending on the value of $x_2$, you can add the term $x_1 x_2$ to the regression. That is called an interaction:


``` r
lm(deliciousness ~ avocado * bacon, data = df)
```

In R, the `*` in the formula means "include both main effects and the interaction." `avocado:bacon` would be just the interaction.

### When to add an interaction

Add it when you have a **theoretical reason** to expect that the effect of one variable depends on another. Then test whether $a_{12} = 0$ — if you reject, that's evidence the interaction is real.

Don't just throw interactions in everywhere; you'll end up with multiple-comparisons issues again, and lots of trivially-significant interaction terms that don't mean anything.

## What you do in general

To summarize this whole "truth about linear regression" topic:

1. Identify which variables could conceivably influence the response.
2. Ask about lurking variables — are there inputs that aren't measured but matter?
3. If you have theoretical justification, add interactions.
4. Check the model with diagnostics.
5. Run the regression and test your specific hypothesis.

Step 5 — testing your hypothesis — is just one step. Most of the work is in 1–4.
