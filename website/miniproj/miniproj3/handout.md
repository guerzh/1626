% Mini-Project 3: COMPAS Recidivism Risk Scores
% MIE 1626


Submission instructions
=======================

Submit an Rmd notebook as well as the PDF generated from the notebook on Gradescope. Pages on Gradescope should be assigned to questions.



Introduction
============

In this part of the project, you will analyze the **COMPAS** recidivism risk scores released by [ProPublica](https://www.propublica.org/article/machine-bias-risk-assessments-in-criminal-sentencing). COMPAS is a commercial tool that assigns each criminal defendant a risk score (a *decile score* from 1 to 10) that is meant to predict whether the defendant will re-offend. Scores like these are used in the United States to inform decisions about bail, sentencing, and parole.

The dataset contains records for over 10,000 defendants from Broward County, Florida, including each defendant's COMPAS score and whether they actually went on to re-offend ("recidivate") within two years. This lets us ask two intertwined questions:

1.  **How good is the score as a predictor?** (a predictive-modelling question)
2.  **Is the score fair across racial groups?** (a fairness question)

These two questions cannot be answered in isolation. A central lesson of this part of the project is that there are several reasonable, *mutually incompatible* definitions of "fair," and a score can satisfy one while violating another. You will compute the relevant quantities yourself and form your own view.

The risk-prediction system you analyze here is a real one that has been used to make decisions about real people. Keep that in mind as you interpret your numbers.



The data
========

The dataset is hosted by ProPublica. You can read it directly from the web:

```r
url <- "https://github.com/propublica/compas-analysis/raw/master/compas-scores-two-years.csv"
raw <- read.csv(url, stringsAsFactors = FALSE)
```

Following ProPublica's analysis, we keep only rows for which the COMPAS screening happened within 30 days of the arrest, for which a recidivism outcome is recorded, and for which the charge degree is a felony or misdemeanour (not an ordinary traffic offence). Apply this filter exactly as below:

```r
library(dplyr)
compas <- raw %>%
  filter(days_b_screening_arrest <= 30,
         days_b_screening_arrest >= -30,
         is_recid != -1,
         c_charge_degree != "O",
         score_text != "N/A")
```

This leaves **6172 defendants**. The first few rows of the columns you will use look like this:

       sex age             race priors_count c_charge_degree decile_score score_text two_year_recid
    1 Male  69            Other            0               F            1        Low              0
    2 Male  34 African-American            0               F            3        Low              1
    3 Male  24 African-American            4               F            4        Low              1
    4 Male  44            Other            0               M            1        Low              0
    5 Male  41        Caucasian           14               F            6     Medium              1
    6 Male  43            Other            3               F            4        Low              0

The columns you will need:

-   `decile_score` --- the COMPAS risk score, an integer from 1 (lowest risk) to 10 (highest risk).
-   `score_text` --- COMPAS's own coarse label: `Low`, `Medium`, or `High`.
-   `two_year_recid` --- the **ground truth**: 1 if the defendant was arrested for a new offence within two years, 0 otherwise. (Overall, about 45.5% of defendants in the filtered data recidivated.)
-   `race` --- self-reported race. The two largest groups are `African-American` (3175 defendants) and `Caucasian` (2103); the remaining groups (`Hispanic`, `Other`, `Asian`, `Native American`) are much smaller. For Parts 1--3 you will compare the two largest groups.
-   `age`, `sex`, `priors_count` (number of prior offences), and `c_charge_degree` (`F` = felony, `M` = misdemeanour) are candidate predictors.

In this part of the project, we treat a defendant as "predicted to re-offend" when their decile score exceeds a threshold that **you** choose --- this is exactly the threshold-on-a-score situation from the ICU project, except the score now comes from COMPAS rather than from a model you fit yourself.



General guidelines
==================

Your code should be general enough that if the dataset were changed (to one with the same column names), the code would still run. In particular, do not hard-code the number 6172 or the names of the racial groups where a `group_by` or a computed value would do.

You will be graded on the correctness of your code as well as on the professionalism of the presentation of your report. The text should be clear; figures should visualize the data well and have appropriate labels and legends. Use `ggplot` for plots and `dplyr`/`tidyverse` for data manipulation.

When you are asked to compute something, use code (rather than computing things outside of R and typing in the answer), and include the code in the report.


### Grading scheme

-   **10 points** for a professional and well-formatted report. Points will be taken off if the report is difficult to read.



Part 1: Score distributions by race (10 pts)
--------------------------------------------

Restrict attention to defendants whose `race` is `African-American` or `Caucasian`. For each of these two groups, plot a histogram of `decile_score` (the scores 1--10). Put the two histograms side by side, or overlay them, so that the shapes can be compared directly.

Describe in words how the two distributions differ. (You are *not* asked to explain *why* they differ here --- just to read the plot.)



Part 2: Errors at a single threshold (15 pts)
---------------------------------------------

We will say a defendant is **classified as high-risk** when their `decile_score` is greater than 4 (so that `Low` scores are "low-risk" and `Medium`/`High` scores are "high-risk"). Treat `two_year_recid` as the ground truth.

Write a function that, given a subset of the data, returns:

-   the **False Positive Rate** --- the fraction of defendants who did *not* re-offend but were classified as high-risk;
-   the **False Negative Rate** --- the fraction of defendants who *did* re-offend but were classified as low-risk;
-   the overall **correct-classification rate** (accuracy).

Report these three numbers separately for African-American and for Caucasian defendants. Comment on what you find: in which direction does each error rate differ between the groups, and why might that be troubling if the score is used to set bail?



Part 3: Errors across thresholds (15 pts)
-----------------------------------------

The choice of threshold 4 in Part 2 was arbitrary. Sweep the threshold over the values `0.5, 1.5, 2.5, ..., 9.5` (i.e. every place a defendant could move from "low-risk" to "high-risk"). For each threshold, compute the False Positive Rate and the True Positive Rate **separately for each of the two groups**.

Produce a plot of True Positive Rate vs. False Positive Rate (an ROC curve) with one curve per group. Does COMPAS appear to rank defendants equally well within each group? Is the *ranking* quality (the shape of each ROC curve) the same thing as the *fairness* you examined in Part 2? Explain in two or three sentences.



Part 4: A logistic-regression model (15 pts)
--------------------------------------------

Now build your own score instead of using COMPAS's. First, split the filtered data into training, validation, and test sets (roughly 60/20/20) by sampling row indices.

Using the **training set**, fit a logistic regression that predicts `two_year_recid` from `age` and `priors_count`:

```r
model <- glm(two_year_recid ~ age + priors_count, family = binomial, data = train)
```

Report the fitted coefficients and interpret the sign and rough magnitude of each one in plain language (what does the `age` coefficient say about who is predicted to re-offend?). Then compare the model's correct-classification rate on the training set to its rate on the validation set, using a threshold of 0.5 on the predicted probability. Is there evidence of over-fitting?



Part 5: Improving the model (10 pts)
------------------------------------

Try adding **at least four** other variables (individually or in combination) to the model from Part 4 --- for example `sex`, `c_charge_degree`, or interactions. Use the **validation set** (not the test set) to decide whether each addition helps. Report what you tried and which model you would choose, and justify the choice using the validation results. Explain why it would be a mistake to make this decision using the test set.



Part 6: Equalizing false positive rates (15 pts)
------------------------------------------------

In Part 2 you (probably) found that a single threshold produces different false positive rates for the two groups. One notion of fairness asks that the false positive rates be **equal** across groups.

Using your chosen model from Part 5, find **group-specific thresholds** --- one for African-American defendants and one for Caucasian defendants --- such that the two groups have (approximately) equal false positive rates, while making the overall correct-classification rate as high as you can subject to that constraint. Describe your search procedure and report the thresholds you chose and the resulting error rates. Use the validation set to choose the thresholds, and report the final numbers on the **test set**.

In two or three sentences, state the cost of this fairness criterion: what do you give up, and for whom, in order to equalize false positive rates?



Part 7: A relationship of your own (10 pts)
-------------------------------------------

Choose two variables in the dataset (other than the pair you were told to use in Part 4) and make a single figure that shows how they relate to each other and to the COMPAS score or to recidivism. Explain what the figure shows and why it is relevant to the fairness questions above.



Part 8: A neural network (10 pts)
---------------------------------

So far your only model has been logistic regression, which is just a neural network with no hidden layer. In this part you will fit a network with **one hidden layer of 10 units** using the `nnet` package, and output its weights.

For the neural network, **throw in the kitchen sink**: use *every* predictor that is known at the time of the COMPAS screening. There is exactly one rule --- you must **not** use any column that records a *future arrest*, because those columns leak the answer. They are recorded *after* the screening and encode the very outcome you are trying to predict, so a model that uses them would look brilliant in your report and be useless in practice. The future-arrest columns to exclude are the target `two_year_recid` itself, `is_recid`, `is_violent_recid`, `violent_recid`, every `r_*` and `vr_*` column (the new charge), and `start`, `end`, `event`. (It also makes sense to drop COMPAS's own score columns --- `decile_score`, `score_text`, the `v_*` scores --- and free-text/identifier/date columns, since the point is to predict the outcome from raw inputs.)

A reasonable kitchen-sink predictor set is:

```r
predictors <- c("sex", "age", "age_cat", "race",
                "juv_fel_count", "juv_misd_count", "juv_other_count",
                "priors_count", "c_charge_degree")
form <- as.formula(paste("two_year_recid ~", paste(predictors, collapse = " + ")))
```

Fit the network on the **training set**:

```r
library(nnet)
set.seed(1)
nn <- nnet(form, data = train, size = 10, maxit = 300, decay = 0.01, trace = FALSE)
```

`size = 10` is the number of hidden units; `decay` is a small amount of weight regularization (which keeps the optimization well-behaved); and because `nnet` is sensitive to the starting point, you must `set.seed` so your report is reproducible.

**Output the weights** with

```r
summary(nn)     # weights, grouped by their destination unit
nn$wts          # the same weights as a single numeric vector
nn$coefnames    # which predictor each input i1, i2, ... corresponds to
```

`summary(nn)` reports the architecture and every weight. Multi-level factors are expanded into 0/1 dummy columns (so `race`, with six levels, contributes five inputs, and so on); with this predictor set the predictors expand to **14 inputs**, and with 10 hidden units and 1 output the network is `14-10-1` and has 161 weights. Your output should begin like this:

    a 14-10-1 network with 161 weights
    options were - decay=0.01
      b->h1  i1->h1  i2->h1  i3->h1  i4->h1  i5->h1  i6->h1  i7->h1  i8->h1  i9->h1
      -1.71    2.22   -0.40   -0.01   -2.03   -0.15    0.40    2.15   -0.01    7.09
    i10->h1 i11->h1 i12->h1 i13->h1 i14->h1
      -0.03    0.59    5.19    0.13    2.68
      b->h2  i1->h2  ...
       ...
      b->o  h1->o  h2->o  ...  h10->o

Here `iN->hj` is the weight from input `N` to hidden unit `j`, `b->hj` is the bias into hidden unit `j`, and `hj->o` is the weight from hidden unit `j` to the output. Use `nn$coefnames` to state in your report which predictor each input number (`i1`...`i14`) corresponds to.



Part 9: Neural network vs. logistic regression (10 pts)
-------------------------------------------------------

A single train/validation/test split gives a noisy estimate of how good each model is --- you might just have gotten a lucky split. To compare the neural network with logistic regression fairly, **resample 10 times**: repeat the whole split-and-fit procedure 10 times with a different random partition each time, and average the results.

Concretely, write a function that does one resample --- it draws a fresh 60/20/20 split, fits **both** the logistic-regression model and the 10-unit neural network on the training set, and returns the correct-classification rate of each model on the validation set and on the test set. To make this a fair, apples-to-apples comparison of the two model *families*, give both models the **same kitchen-sink predictors** (`form`) from Part 8. Then call it 10 times and average:

```r
acc <- function(prob, truth) mean((prob > 0.5) == (truth == 1))

compare_once <- function() {
  n   <- nrow(compas)
  idx <- sample(n)
  tr  <- idx[1:(0.6*n)]; va <- idx[(0.6*n+1):(0.8*n)]; te <- idx[(0.8*n+1):n]
  train <- compas[tr, ]; val <- compas[va, ]; test <- compas[te, ]

  g  <- glm(form, family = binomial, data = train)
  nn <- nnet(form, data = train, size = 10, maxit = 300, decay = 0.01, trace = FALSE)

  c(glm_val  = acc(predict(g,  val,  type = "response"), val$two_year_recid),
    nn_val   = acc(as.vector(predict(nn, val)),          val$two_year_recid),
    glm_test = acc(predict(g,  test, type = "response"), test$two_year_recid),
    nn_test  = acc(as.vector(predict(nn, test)),         test$two_year_recid))
}

set.seed(1)
results <- replicate(10, compare_once())
rowMeans(results)
```

A typical run gives numbers close to

     glm_val   nn_val glm_test  nn_test
       0.672    0.670    0.675    0.673

Report your averaged validation and test accuracies for both models. Then answer: is the difference between the neural network and logistic regression **larger or smaller** than the spread across the 10 resamples? (Look at `apply(results, 1, sd)` --- here it is about `0.01`, several times *larger* than the gap between the two models.) What does that tell you about whether the extra flexibility of the hidden layer is buying you anything on this dataset?



Part 10: Interpreting the hidden units (10 pts)
-----------------------------------------------

The output of `summary(nn)` lists, for every hidden unit, the weights coming into it from each input (plus a bias), and the single weight carrying that unit's activation to the output. This lets you give each unit a rough "job description."

For each of the 10 hidden units, read off its incoming weights (use `nn$coefnames` to translate `i1`...`i14` into predictor names) and report which input(s) it responds to most strongly (largest absolute weights) and the sign of its connection to the output (`hj->o`). Then, **in one sentence per unit**, interpret what that unit appears to detect. For example, a unit with a large positive weight on `priors_count` and a positive `h->o` weight is acting as a "many-priors ⇒ higher predicted risk" detector, whereas a unit whose weights are all near zero is doing little.

Finally, comment on the limits of this exercise: hidden units in a network are not guaranteed to be individually meaningful (several can be redundant, or split one concept between them), which is part of why a neural network is harder to *explain to a defendant* than the logistic regression of Part 4. Tie this back to the fairness discussion: why does interpretability matter when a model is used to make decisions about people?



Part 11: A decision tree (10 pts)
---------------------------------

Finally, fit a model that is at the opposite end of the interpretability spectrum: a **decision tree**, using the `rpart` package. As with the neural network, **throw in the kitchen sink** --- use the same `form` (every predictor known at screening, no future-arrest columns). A tree handles many predictors gracefully: it will simply ignore the ones it does not find useful, so you can see which features it chooses to split on. Fit it on the training set and visualize it:

```r
library(rpart)
set.seed(1)
tree <- rpart(update(form, factor(two_year_recid) ~ .),
              data = train, method = "class")

plot(tree, margin = 0.1)   # draw the branches
text(tree, use.n = TRUE)   # label the splits and leaves
```

(If you have the `rpart.plot` package, `rpart.plot(tree)` produces a nicer figure --- either is acceptable.)

Include the tree in your report and describe it: which variable does the tree split on first, and what does that say about which feature is most predictive of recidivism? Follow one path from the root to a leaf and state, in plain language, the rule it represents (e.g. "a defendant with more than X prior offences and age below Y is predicted to re-offend").

Compare the three model families you have now fit --- logistic regression, the neural network, and the decision tree --- in one paragraph: which is easiest to explain to the person being scored, which performed best in Part 9, and how you would weigh accuracy against explainability if this model were actually used to set bail.
