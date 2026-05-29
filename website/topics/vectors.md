---
title: "Vectors in R"
output:
  html_document: default
  pdf_document: default
---



## Vectors

In R you usually operate on **vectors**. (These are similar to numpy arrays if you are more familiar with numpy.) Vectors are defined using the `c()` operator, which also stands for "concatenate" (similarly to `cat`, just different histories):


``` r
offer <- c(241, 590, 533, 425, 261)
offer
```

```
## [1] 241 590 533 425 261
```

This is a vector. You can access elements of it using e.g. `offer[1]`. **R, unlike Python, is one-based:**


``` r
offer[1]
```

```
## [1] 241
```

``` r
offer[2]
```

```
## [1] 590
```

You can index a range:


``` r
offer[2:5]
```

```
## [1] 590 533 425 261
```

`length` gives you the length:


``` r
length(offer)
```

```
## [1] 5
```

Technically everything is a vector. If you define it like `a <- 42`, that is the same as saying `c(42)`; it is just a vector of length one.

`sort`, `unique`, `min`, `max` do what you'd expect:


``` r
sort(offer)
```

```
## [1] 241 261 425 533 590
```

``` r
unique(c(1, 1, 2, 3))
```

```
## [1] 1 2 3
```

``` r
min(offer)
```

```
## [1] 241
```

``` r
max(offer)
```

```
## [1] 590
```

Here is a way to do `max` that is kind of weird: sort, then get the last element by `length(offer)`:


``` r
sort(offer)[length(offer)]
```

```
## [1] 590
```

It is the same answer as `max(offer)`.

## Boolean operations on vectors

You can do boolean operators that apply elementwise:


``` r
offer > 533
```

```
## [1] FALSE  TRUE FALSE FALSE FALSE
```

So `offer > 533` produces a vector of `FALSE`s and `TRUE`s. (`F` and `T` are shorthand for `FALSE` and `TRUE`.)


``` r
offer < 550
```

```
## [1]  TRUE FALSE  TRUE  TRUE  TRUE
```

In R, as well as in pandas, a lot of what you do is index using a vector of `FALSE`s and `TRUE`s. You can just say:


``` r
offer[c(F, T, F, F, F)]
```

```
## [1] 590
```

This selects the elements that correspond to `TRUE`. So very often you will see people doing:


``` r
offer[offer > 533]
```

```
## [1] 590
```

That selects the elements of `offer` that are greater than 533. Recall that `FALSE` means "drop" and `TRUE` means "keep".

## Combining conditions

In R you use `&` for AND, `|` for OR, and `!` for NOT:


``` r
offer > 400 & offer < 550
```

```
## [1] FALSE FALSE  TRUE  TRUE FALSE
```

``` r
offer[offer > 400 & offer < 550]
```

```
## [1] 533 425
```

Here, `TRUE` corresponds to elements that are both greater than 400 and smaller than 550. So this gets the elements between 400 and 550.

The elements of `offer` outside the range 400..550:


``` r
offer[!(offer > 400 & offer < 550)]
```

```
## [1] 241 590 261
```

``` r
offer[offer <= 400 | offer >= 550]
```

```
## [1] 241 590 261
```

The `!` operator turns `TRUE` into `FALSE` and vice versa, so we keep the elements we dropped before and drop the elements we kept.

### Pie or ice cream

Here is the classic example, just to amuse people. Let's say that you want to say "for dessert I'll have pie or ice cream". In English what we usually mean is *either pie or ice cream, but not both*. In R and in Python the `or` does **not** work like that:


``` r
pie <- TRUE
ice_cream <- TRUE
pie | ice_cream
```

```
## [1] TRUE
```

This is `TRUE` because both `pie` is `TRUE` and `ice_cream` is `TRUE`. That would be unfortunate at the dessert table.

How do you say it correctly? It is an annoying thing because there is a very simple answer: `pie | ice_cream` means exactly one is true if `pie != ice_cream` (one is true, the other is false):


``` r
pie != ice_cream
```

```
## [1] FALSE
```

You can also do a more complicated expression:


``` r
(pie | ice_cream) & !(pie & ice_cream)
```

```
## [1] FALSE
```

This says: one is true, but it is not true that they are both true. Equivalently:


``` r
(pie & !ice_cream) | (!pie & ice_cream)
```

```
## [1] FALSE
```

## Parallel vectors

Those were the average offers to various specialties of doctors (US, 2018). Let's also store the specialties:


``` r
offer <- c(241, 590, 533, 425, 261)
spec <- c("family doc", "cardiologist", "orthopedic", "dermatologist", "psychiatrist")
```

So for example, the offers to cardiologist were \$590k per year in 2018. Suppose we want to automatically figure out which specialty makes the most money.

If we knew it were specialty number 2, we'd just do `spec[2]`. But how do we figure out the `2`?

We'd like to compute `spec[c(F, T, F, F, F)]`. Can we compute the logical vector? Here is an idea:


``` r
offer == max(offer)
```

```
## [1] FALSE  TRUE FALSE FALSE FALSE
```

Combining those ideas:


``` r
spec[offer == max(offer)]
```

```
## [1] "cardiologist"
```

If you just wanted the maximum offer, you could do this:


``` r
offer[offer == max(offer)]
```

```
## [1] 590
```

This is just `max(offer)` again, but it is a useful pattern.

So how do we get the index `2`? We can generate the vector `1:length(offer)`:


``` r
1:length(offer)
```

```
## [1] 1 2 3 4 5
```

And now we can simply do:


``` r
(1:length(offer))[offer == max(offer)]
```

```
## [1] 2
```

If you have an index, you don't need to do it that way to get the actual specialty — this is just for fun:


``` r
idx <- (1:length(offer))[offer == max(offer)]
spec[idx]
```

```
## [1] "cardiologist"
```

These days, those things are changing because you are mostly doing this with LLMs. LLMs would generally not give you something like that. But sometimes you still work with vectors and you have got to read code.
