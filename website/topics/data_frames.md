---
title: "Data Frames"
output:
  html_document: default
  pdf_document: default
---



## Data frames

The usual way that you work with data in R is **data frames**. A data frame is basically a table. The advantage is you don't have to manually keep track of what corresponds to what — if you have a table, you just have rows.

A lot of the time you just read it from a file, so you do not have to define it manually. But if you do, in R it works like this: you say `data.frame`, then the name of the column, then the contents of the column as a vector.


``` r
df <- data.frame(
  offer = c(241, 590, 533, 425, 261),
  spec = c("family doc", "cardiologist", "orthopedic", "dermatologist", "psychiatrist")
)
df
```

```
##   offer          spec
## 1   241    family doc
## 2   590  cardiologist
## 3   533    orthopedic
## 4   425 dermatologist
## 5   261  psychiatrist
```

This is now a table.

## The babynames data set

You need to do this the first time:


``` r
install.packages("babynames")
```

Once installed:


``` r
library(babynames)
head(babynames)
```

```
## # A tibble: 6 × 5
##    year sex   name          n   prop
##   <dbl> <chr> <chr>     <int>  <dbl>
## 1  1880 F     Mary       7065 0.0724
## 2  1880 F     Anna       2604 0.0267
## 3  1880 F     Emma       2003 0.0205
## 4  1880 F     Elizabeth  1939 0.0199
## 5  1880 F     Minnie     1746 0.0179
## 6  1880 F     Margaret   1578 0.0162
```

The dataset has the most common names in the US. So in 1880 there were 7,065 Marys registered as being born in the US.

Technically `babynames` is what is called a **tibble** rather than a plain data frame. A tibble is just a variation on the word "table" that is specific to R. It is basically a special kind of data frame, and prints more nicely.

## Accessing rows and columns

You can access something like row number two, the column `year`, by doing this:


``` r
babynames[2, "year"]
```

```
## # A tibble: 1 × 1
##    year
##   <dbl>
## 1  1880
```

Get just the first several rows with `head`. Get a specific row and column:


``` r
babynames[500, "name"]
```

```
## # A tibble: 1 × 1
##   name 
##   <chr>
## 1 Dessa
```

You can use the column index:


``` r
babynames[500, 3]
```

```
## # A tibble: 1 × 1
##   name 
##   <chr>
## 1 Dessa
```

You can give a range of rows and several columns at once:


``` r
babynames[2:6, "year"]
```

```
## # A tibble: 5 × 1
##    year
##   <dbl>
## 1  1880
## 2  1880
## 3  1880
## 4  1880
## 5  1880
```

``` r
babynames[2:6, c("year", "name")]
```

```
## # A tibble: 5 × 2
##    year name     
##   <dbl> <chr>    
## 1  1880 Anna     
## 2  1880 Emma     
## 3  1880 Elizabeth
## 4  1880 Minnie   
## 5  1880 Margaret
```

You can also access just the data from a particular column using the dollar sign:


``` r
head(babynames$name)
```

```
## [1] "Mary"      "Anna"      "Emma"      "Elizabeth" "Minnie"    "Margaret"
```

The dollar sign is subtly different from the bracket syntax: `babynames$name` gives you a **vector**, whereas `babynames["name"]` (without a row) gives you a **data frame** that's just that column.


``` r
head(babynames["name"])
```

```
## # A tibble: 6 × 1
##   name     
##   <chr>    
## 1 Mary     
## 2 Anna     
## 3 Emma     
## 4 Elizabeth
## 5 Minnie   
## 6 Margaret
```

## Subsetting rows with a boolean mask

You can subset with a boolean mask. For example, if you want the data from the year 1999 with `sex == "F"`:


``` r
babies99 <- babynames[babynames$year == 1999 & babynames$sex == "F", ]
head(babies99)
```

```
## # A tibble: 6 × 5
##    year sex   name         n    prop
##   <dbl> <chr> <chr>    <int>   <dbl>
## 1  1999 F     Emily    26539 0.0136 
## 2  1999 F     Hannah   21673 0.0111 
## 3  1999 F     Alexis   19234 0.00988
## 4  1999 F     Sarah    19102 0.00982
## 5  1999 F     Samantha 19036 0.00978
## 6  1999 F     Ashley   18136 0.00932
```

What happened: `babynames$year == 1999` is a vector of `TRUE`/`FALSE`, `babynames$sex == "F"` is another vector of `TRUE`/`FALSE`. We combined them with `&` so the entry is `TRUE` only when the year is 1999 and the sex is F. Then we said all of the columns by leaving the second slot empty.

We can get the maximum count from `babies99`:


``` r
max(babies99$n)
```

```
## [1] 26539
```

And, in the same way that we did with the salaries, we can find the name that corresponds to the maximum:


``` r
babies99[babies99$n == max(babies99$n), "name"]
```

```
## # A tibble: 1 × 1
##   name 
##   <chr>
## 1 Emily
```

## A function: most common name for a year and sex

Let's say that we want the most common name for a particular year and sex. One way: get a data frame with just that year and sex, then use the same trick as before — find rows where the count equals the maximum and pick out the name.


``` r
most_common <- function(year, sex){
  df <- babynames[babynames$year == year & babynames$sex == sex, ]
  df[df$n == max(df$n), "name"]
}

most_common(1999, "F")
```

```
## # A tibble: 1 × 1
##   name 
##   <chr>
## 1 Emily
```

``` r
most_common(1880, "M")
```

```
## # A tibble: 1 × 1
##   name 
##   <chr>
## 1 John
```
