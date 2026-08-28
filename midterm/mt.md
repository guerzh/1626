# MIE 1626 — Data Science Methods and Statistical Learning

## Test 1 (Midterm)

**Duration:** 1 hour 10 minutes &nbsp;&nbsp;|&nbsp;&nbsp; **Aids allowed:** the test reference sheet distributed with the exam (open handout)

**Language:** R. You may assume the `tidyverse` is loaded (`library(tidyverse)`), and that the datasets named in each question are already available as data frames. Verb signatures (`group_by`, `summarize`, `filter`, `arrange`, `lm`, `glm`, `sample`, `replicate`, `plogis`, …) are on the reference sheet — you do **not** need to memorize exact syntax, and minor syntax slips are not penalized. You are **not** required to write `ggplot` code; where a plot is involved you are asked to *describe* or *read* it.

Answer directly on this paper in the space provided. Where you are asked to write code, short R that a person could write on paper is expected; no error checking is required and you may assume all inputs are valid.

---

### Question 1 — Functions in R [12 marks]

**(a) [6 marks]** Suppose you are given three one-argument functions `f`, `g`, and `h` (already defined). Write R code that defines a function `chained(x)` that returns `f(g(h(x)))`, and show one example call. For concreteness you may *make up* simple definitions of `f`, `g`, and `h` (e.g. doubling, adding one, squaring) so that your example produces a concrete number.

**(b) [6 marks]** Consider the function

```r
SpecialSquare <- function(num){
  if(num == 42){
    return(0)
  }else{
    return(num**2)
  }
}
```

Write R code that computes `SpecialSquare` of **each** of the integers `seq(1, 50)`, returning a vector of length 50. (There is more than one acceptable way to do this in R.)

---

### Question 2 — Gapminder [8 marks]

The `gapminder` data frame contains one row per country per year. Its first rows look like this:

```
      country continent year lifeExp      pop gdpPercap
1 Afghanistan      Asia 1952  28.801  8425333  779.4453
2 Afghanistan      Asia 1957  30.332  9240934  820.8530
3 Afghanistan      Asia 1962  31.997 10267083  853.1007
4 Afghanistan      Asia 1967  34.020 11537966  836.1971
5 Afghanistan      Asia 1972  36.088 13079460  739.9811
6 Afghanistan      Asia 1977  38.438 14880372  786.1134
```

The years recorded are `1952, 1957, 1962, 1967, 1972, …` (five-year steps), and `continent` takes the values `Africa, Americas, Asia, Europe, Oceania`.

Write R code that computes the **continent with the highest median `lifeExp` in the year 1967**. Your code should return the name of that continent (or a one-row summary identifying it).

---

### Question 3 — Baby names [8 marks]

The `babynames` data frame has one row per (`year`, `sex`, `name`) combination, giving the number `n` of US babies of that sex given that name in that year. Its first rows:

```
  year sex      name    n       prop
1 1880   F      Mary 7065 0.07238359
2 1880   F      Anna 2604 0.02667896
3 1880   F      Emma 2003 0.02052149
4 1880   F Elizabeth 1939 0.01986579
5 1880   F    Minnie 1746 0.01788843
6 1880   F  Margaret 1578 0.01616720
```

Write R code that computes **the number of babies born corresponding to the most popular baby name in 1982** — that is, find the name with the largest total count `n` (summed over both sexes) among babies born in 1982, and report that total count.

---

### Question 4 — Estimating a slope three ways [18 marks]

Data were generated from a relationship of the form

$$ y = a\,x + \varepsilon, \qquad \varepsilon \sim \mathcal{N}(0, \sigma^2), $$

and stored in a data frame `d` with columns `x` and `y` (60 rows). The first rows are:

```
      x      y
1 0.675  1.234
2 0.254 -9.641
3 6.305 21.037
4 9.141  9.622
5 6.671 11.372
6 8.744 22.385
```

Running `summary(lm(y ~ x, data = d))` produces:

```
Call:
lm(formula = y ~ x, data = d)

Residuals:
   Min     1Q Median     3Q    Max 
-9.300 -2.912 -0.212  2.360 10.367 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)   -2.080      1.151  -1.806   0.0761 .  
x              2.202      0.211  10.435 6.24e-15 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 4.472 on 58 degrees of freedom
Multiple R-squared:  0.6525,	Adjusted R-squared:  0.6465 
F-statistic: 108.9 on 1 and 58 DF,  p-value: 6.245e-15
```

**(a) [6 marks]** Using **only the summary above**, give a point estimate of $a$ together with an approximate 95% confidence interval. Show the arithmetic.

**(b) [6 marks]** Describe how you would estimate $a$ by **directly minimizing the appropriate linear-regression loss function**, without calling `lm`. Write down the loss as a function of the candidate slope (and intercept), and **write R code** that finds the minimizing value. *(We have not covered how to quantify uncertainty in this case, so a point estimate is all that is required here.)*

**(c) [6 marks]** Describe how you would estimate $a$ **and its uncertainty using a Bayesian approach**, so that your answer corresponds to a region that contains the true value of $a$ with 95% probability. State your prior, what the posterior is over, and how you would extract the 95% region from samples or from the posterior. *(This was not covered directly — some creative thinking is expected.)*

---

### Question 5 — Weak relationship, tiny p-value [12 marks]

Write R code that **generates data** `x` and `y` for which the relationship between them is *weak* (a small effect size / low $R^2$), yet the p-value reported by `lm(y ~ x)` for the slope comes out *very small*. (You do not need to guarantee any exact threshold — it just needs to be very small.) Explain in one or two sentences **why** your construction produces this combination, and what this tells us about interpreting small p-values.

---

### Question 6 — Insurance on the Titanic [16 marks]

You have the `titanic` (training) data frame — one row per passenger — and you are tasked with selling drowning insurance to passengers as they board. The first rows of the relevant columns are:

```
  Survived Pclass    Sex Age SibSp Parch    Fare
1        0      3   male  22     1     0  7.2500
2        1      1 female  38     1     0 71.2833
3        1      3 female  26     0     0  7.9250
4        1      1 female  35     1     0 53.1000
5        0      3   male  35     0     0  8.0500
6        0      3   male  NA     0     0  8.4583
```

(`Survived` is 1 if the passenger survived and 0 otherwise; the data frame has 891 rows.) You set the insurance **premium** per passenger. The **payout** in case of drowning is always \$100. If the passenger survives, they do **not** get the premium back, and they do **not** get the payout.

**(a) [8 marks]** Propose a reasonable formula representing a single passenger's **decision** of whether to buy the insurance, given the premium you offer them. State your assumptions about how a passenger values the \$100 payout and the premium, and write the condition under which they buy.

**(b) [8 marks]** Suppose you are allowed to use only `Pclass` and `Age` to price each passenger. State how you would produce a formula for the **smallest premium that does not lead to an expected loss** for you, and state precisely how you would use that formula to set a price for a new passenger of given `Pclass` and `Age`. *(Hint: relate the break-even premium to an estimated probability of drowning.)*

---

### Question 7 — Critiquing the model [10 marks]

In **English** (no code), critique the insurance pricing model you produced in Question 6: give **two** distinct reasons why the prices might be wrong if the model were actually used. Be specific about the mechanism behind each reason.

---

### Question 8 — The desk-drawer (file-drawer) effect [16 marks]

A research community has **100 researchers**. Each runs one experiment. **10%** of the hypotheses being tested are *true* (there is a real effect) and **90%** are *false* (no real effect). A result is *reported* (published) only when the researcher **rejects the null hypothesis**; experiments that fail to reject the null are filed away in a desk drawer and never reported.

Using a **simulation** (you must use a simulation — not a closed-form formula), estimate **what proportion of the reported results are false positives**. The output of your code should be that proportion.

Write the R code (`sample`, `runif`, `rbinom`, `replicate`, … are available) and **state any assumptions** you make — in particular the significance level $\alpha$ used for false hypotheses and the statistical power used for true hypotheses.

---

*End of Test 1.*
