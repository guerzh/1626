---
title: "Interpreting p-values, Errors, and the Replication Crisis"
output:
  html_document: default
  pdf_document: default
---



## Is the 5% threshold reasonable?

Is the 5% threshold arbitrary? **Yes.** It is a historical thing, decided by Ronald Fisher, who was the founder of this specific field.

The interpretation is: if the null hypothesis is true, you would reject it 5% of the time. In a way, 5% is the acceptable rate of *incorrectly* rejecting the hypothesis.

5% might sound like a lot. In different fields the standards are different. Famously in particle physics — where they try to detect new particles by computing a p-value — the standards are around $10^{-10}$, not $0.05$. Because if you accidentally announce a new particle one time in 20, that's too often.

On the other hand, in social science the sample sizes are usually small. Even if the effect is real, getting a small p-value is hard. So with very strict standards you cannot conclude anything about social science. Most people also think that more than half of social-science findings are not correct, which is partly an artifact of the 5% threshold: if 20 research groups test different social-science hypotheses, even if all the hypotheses are not correct, on average 1 in 20 of those groups would find something every time. They run more than one experiment a year — so all your hypotheses could be wrong and you still publish papers.

## The ASA statement on p-values

The American Statistical Association issued, about 10 years ago, an official statement on p-values. It's basically a disclaimer on how to use them. The six principles:

1. **p-values can indicate how incompatible the data are with a specified statistical model.** It is *not* the probability that the hypothesis is true or false. The probability of what? The probability of observing a test statistic as extreme as the one observed, *assuming the null hypothesis is true*. ("What is a p-value?" is a classic interview question. The correct answer is exactly that.)

2. **p-values do not measure the probability that the studied hypothesis is true,** nor the probability that the data were produced by random chance alone. A p-value *is* a probability, just not that one — it's the probability that the data as extreme or more extreme would be produced by random chance, *assuming the null hypothesis is true*.

3. **Scientific conclusions and business or policy decisions should not be based only on whether a p-value passes a specific threshold.** Despite the fact that everyone does this, it's not the ASA's recommendation that you binarize at 5%.

4. **Proper inference requires full reporting and transparency.** You cannot just report the p-value without context — what assumptions did you make about the data? Did you check that the data is actually Gaussian?

5. **A p-value (or statistical significance) does not measure the size of an effect or the importance of a result.** The test statistic measures the effect size (in some units); the p-value is a probability. Also, the p-value is a function of two things: the size of the effect *and* the sample size. With a very large sample you can detect very small differences — so a small p-value could just indicate that you have a lot of data.

6. **By itself, a p-value does not provide a good measure of evidence regarding a model or hypothesis.** This is kind of "don't pay attention to p-values" — which is kind of true, but also: how else are you supposed to do statistics?

An analogy: there is a warning on Q-tip boxes that says you are not supposed to use Q-tips to clean your ears, even though that is what most people use them for. These are sensible warnings, but how else can you clean your ears, and what else are you supposed to use Q-tips for? (Don't stick Q-tips in your ears — your ears are self-cleaning. It's all fine.)

## "Are we 95% sure the hypothesis is false if $p < 0.05$?"

That is how people often read it. The answer is no, technically. $p = 0.05$ is not the probability the hypothesis is false, not the probability it is true. It is only the probability of observing something as surprising as what we did, *given that $H_0$ is true*. So the probability is computed first by *assuming* $H_0$ — it has nothing to do with the probability of $H_0$ itself.

That said, as we saw in the Bayesian inference topic, you can think about the probability of the hypothesis being true or false in Bayesian terms, which brings us back to something like the "95% sure" reading — but if you just compute the p-value, no, you cannot say that.

## When can we conclude anything at all?

You have to look at the data. Ideally, you predecide that you will look at the data and compute the p-value, and if it turns out smaller than 5%, you can say "I rolled the dice, I measured the data, it turns out I got something that looks surprising, so I can report it."

## Types of errors

### Type I and Type II

The standard theory. Common interview question.

- **Type I error**: rejecting the null hypothesis even though it is not false. If your threshold is 5%, then 5% of the time when you reject (given $H_0$ is actually true) you'll commit a Type I error.
- **Type II error**: not rejecting the null hypothesis even though it is false. The probability that this happens depends on the sample size. With a very large sample size, p-values are basically automatically small, so you reject every time.

### Gelman: "I've never made a Type I or Type II error"

A somewhat provocative quote from a blog post by Andrew Gelman, the famous statistician. He claims: *"I've never in my professional life made a Type I error or a Type II error. But I've made lots of errors."*

How can this be?

A Type I error happens if the null hypothesis is true and you reject it anyway. But the null hypothesis in social science is essentially never literally true. Think back to the birds: $H_0$ is that the mean beak depth in 1976 equals the mean beak depth in 1978. There is absolutely no way that this is literally true — there's a finite number of birds in 1976 and a finite number in 1978; both numbers exist; they are almost definitely not exactly equal.

So: if the null is never literally true, Type I errors are not really a thing. When you reject, you are always (in some sense) correct.

For Type II — there's a bit of an equivocation. Technically a Type II error is "not rejecting an $H_0$ which is false", and if $H_0$ is never true anyway then "not rejecting" doesn't really matter. But people sometimes slide from "not rejecting" to "accepting", and *accepting* a never-true hypothesis is wrong — but if you only ever reject and never claim that $H_0$ is true, you never make a Type II error in that strict sense either.

This is just a cheeky blog post, but it's worth keeping in mind.

### Type S and Type M errors

What's the alternative? People agree this is how you *should* think about it, even if it's not how social science and medical science actually practice. The alternative typology:

- **Type S error** ("sign"): claiming that the effect is positive when it is actually negative (or vice versa).
- **Type M error** ("magnitude"): claiming there is a large-magnitude effect when actually the effect is small.

The claim here is to reframe "Type I / Type II" — those errors aren't actually things if you think about them rigorously. But Type S and Type M errors are big and real. Most non-replicating social-science studies are Type M errors: maybe the effect direction is right, but the estimate of how important it is, is completely off.

## Why most published findings might be false

This is the title of a famous (and now even more famous, for unrelated reasons) paper by John Ioannidis. The argument:

In an ideal world, if you only publish results with $p < 0.05$, 5% of all studies are incorrect. That is what 5% means.

Two things complicate it:

### Publication bias / file-drawer effect

If you only try to publish studies with small p-values and just don't report studies where you didn't get small p-values, it is like rolling a die and only telling your friends when you got 12. If you rolled an 11, you don't tell anyone and try again. So it might look like you get 12 every time. The metaphor is "you put the unpublished papers that nobody's going to accept because $p$ is too large in the desk drawer."

### p-hacking

People just lie. So that also happens. One thing you can do is look at the p-values people report and plot them. A lot of the time, you see suspiciously many people reporting $p = 0.049$ — way more than report $p = 0.048$. That is because they pushed and prodded until they got it. Modest estimates of the false-discovery rate are 15%; nobody really knows.

### The "garden of forking paths"

p-hacking is when you deliberately try different hypotheses on the same data until something is significant. Everyone agrees that's bad and unethical. More commonly: the **garden of forking paths**, in which the same thing happens without ill intent.

You start with an overall idea: maybe big beaks help eat tough seeds. You test it. Didn't work. Maybe small beaks let you pick at little pieces? Try it. Eventually you get something that works out.

Why "garden of forking paths"? It refers to a story by Jorge Luis Borges, the famous Argentinian writer. The hypotheses live in a garden with multiple paths. You can justify going right; you can justify going left. Eventually you get to something with a small p-value, but that's not necessarily meaningful.

### Bad model

If the distribution is not really Gaussian, then everything you do with the closed-form Gaussian-based p-value formula is not actually computing anything meaningful. The formula returns a number; the number does not correspond to anything.

### Working things in choices

A real example. A study reported that "the upper-body strength of modern adult men influences their willingness to bargain in their own self-interest over income and wealth redistribution." Some criticisms:

- Two of the experiments were college students. It wasn't really across cultures.
- They did not measure anybody's upper body strength. They measured arm circumference — which is not the same.

Lots of choices there. Maybe they pre-decided to measure arm circumference, in which case fine. But maybe they tried different measures and only arm circumference worked. That is a problem because then the conclusion about "upper-body strength" is not actually doing what it claims.

## Remedies

Given all those problems:

- **Don't believe one study.** That is what doctors do — they read medical journals, but if a patient says "I read this one study about this drug, can I have it?", the doctor says "no, this is one study; there are lots of studies, most of them are not correct." You never believe one study; you believe a body of literature. It is still 15–50% false, but it gives you something.
- **Replication.** Look at attempts to do the same study.
- **Meta-analysis.** Someone collects all the papers on the same topic and looks at all the effect sizes.
- **Pre-registration.** Specify the hypothesis being tested before collecting the data; commit to reporting that. This is the remedy to publication bias: if I commit to telling you what came out before I roll the dice, then there is no problem if I only tell you when I hit 12.
- **A theory.** "Big beaks help eat tough seeds" is at least something. If you just say "I have this data, I'm going to measure something", that is probably p-hacking waiting to happen.

## The dead-salmon study

A famous fMRI parody study: *Neural correlates of interspecies perspective taking in the postmortem Atlantic salmon*. They take a salmon — a fish — put it in an MRI machine, show it human faces (some happy, some sad), and look at which neurons in the salmon's brain activate differently for happy versus sad faces.

The most impressive part: **the salmon was dead** when it was in the MRI machine.

This was published as a parody. The point: if you do a statistical test at every location in the fish's brain, you will get a "significant" value somewhere just by random chance. With many tests, you will hit Type I errors no matter what the data is, even if it is a dead salmon.

(Or maybe Atlantic salmon really can do interspecies perspective taking. That is also possible.)

This is the **multiple comparisons** problem in pictorial form. Whenever you have a lot of tests, you have to expect false positives.
