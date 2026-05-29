% Mini-Project 1
% MIE 1626


Submission instructions
=======================
Submit an Rmd notebook as well as the PDF generated from the notebook on Gradescope. 



Part 1: Operating on Dataframes (33 pts)
-------------------------------

Install the `babynames` package using `install.packages("babynames")` and load it using `library(babynames)`. `install.packages('dplyr')` and `library(dplyr)` to load the `dplyr` package. You should use the `summarize`, `group_by`, `mutate`, and `filter` functions from the `dplyr` package to complete the following tasks. Use the `ggplot2` package to create the required plots. You can install and load `ggplot2` using `install.packages("ggplot2")` and `library(ggplot2)`.

a. Write code to compute the total number of babies born in each year. Plot the total number of babies born per year as a line plot.

b. Write code to compute the proportion of babies born with the name "Emma" in each year. Plot the proportion of babies named "Emma" per year as a line plot.

c. Write code to compute the proportion of male and female babies in the dataset born in each year.

d. Write code to compute the top 5 most popular names for each year. Plot the number of babies born with each of these names per year as a line plot, with one line per name.


Part 2: Bayesian Inference (33 pts)
------------------------------

For this part, you will demonstrate that both the prior distribution you choose and the sample size affect the posterior distribution of the parameter of interest.

Consider a situation where you flip a coin with $P(\text{heads}) = p$, $n$ times. You want to estimate $p$, the probability of getting heads.

For $n = 100$, $p = 0.4$, and a uniform prior distribution on $p$, simulate 1000 datasets, and plot the histogram of the maximum a posteriori (MAP) estimates of $p$ across the 1000 datasets. Repeat the same for $n = 500$ and $n = 2000$. Comment on what you observe from the plots.

Now, vary the shape of the prior distribution. Demonstrate how that affects the posterior distribution of $p$ (rather than just the MAP estimate). Display at least 3 different situations with different shapes of the posterior distribution.



Part 3: Low P-values (34 pts)
-----------------------------

For this part, you should demonstrate that low p-values do not
necessarily imply an important association between two variables.

Write a function to generate a dataset $(X, Y)$ containing $n$ data
points, such that

$$ Y^{(i)} = a_0 + a_1 X^{(i)} + \epsilon_i, \qquad \epsilon_i \sim \mathcal{N}(0, \sigma). $$

Set the parameters to be such that the relationship between $X$ and
$Y$ is very weak. State what the parameters are, and plot $Y$ vs.
$X$.

Now, show that for larger $n$, you will nearly always reject the
hypothesis that $a_1 = 0$, even if $a_1$ is very close to $0$. Make
an appropriate figure to demonstrate this fact. Think of a way to
make the figure convincing.
