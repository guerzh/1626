% Mini-Project 2: Predicting In-Hospital Deaths in the ICU
% MIE 1626


Submission instructions
=======================
Submit an Rmd notebook as well as the PDF generated from the notebook on Gradescope. Pages on Gradescope should be assigned to questions.



Introduction
============

In this assignment, you will build a system for predicting patient
deaths in the Intensive Care Unit (ICU) using the large
[PhysioNet Computing in Cardiology Challenge 2012 dataset](https://physionet.org/content/challenge-2012/1.0.0/).
For each patient in the dataset, demographic variables and time
series of physiological variables were collected during their stay
in the ICU.

Clinical risk prediction from physiological measurements, clinical
notes, and demographic data using machine learning has seen
advances in recent years. For example, see this
[article](https://www.businessinsider.com/google-patent-hints-electronic-health-record-market-plans-2019-2)
about Google's efforts in the area.

The risk prediction system you will build could in principle be
used to flag patients as being at risk of death so that physicians
could intervene and improve their outcome. To be confident about
the impact of such a system, you would need to run an experiment.
In this assignment, you will use a model in order to estimate the
potential impact of the system.

The data you will be working with is all available from
[PhysioNet](https://physionet.org/challenge/2012/). You will be
looking at only the data in "Training set A". The patient data
files are
[here](https://physionet.org/files/challenge-2012/1.0.0/set-a.zip),
and the outcomes file is
[here](https://physionet.org/files/challenge-2012/1.0.0/Outcomes-a.txt).



General guidelines
==================

Your code should be general enough that if the dataset were
changed, the code would still run.

You will be graded on the correctness of your code as well as on
the professionalism of the presentation of your report. The text
of your report should be clear; the figures should do a good job
of visualizing the data, and should have appropriate labels and
legends. Overall, the document you produce should be easy to read
and understand.

When you are asked to compute something, use code (rather than
compute things outside of R and then input the answer), and
include the code that you used in the report. (You may deviate
from this if the computation is really trivial.)

### Grading scheme

- **10 points** for a professional and well-formatted report.
  Points will be taken off if the report is not well-formatted and
  is difficult to read.



Part 1: Reading in the Data (10 pts)
------------------------------------

First, you should download the patient data and patient outcomes
file. Download
[set-a.zip](https://physionet.org/challenge/2012/set-a.zip),
extract all the files from it to a directory, and download
[Outcomes-a.txt](https://physionet.org/challenge/2012/Outcomes-a.txt)
to the same directory (i.e., in `set-a`). To extract files from a
`zip` file, open the `zip` file, and then drag the files that you
see in a window that opens to whatever directory you want.

Read in the files as follows. Your working directory must be set
to the directory that contains the text files you extracted. If
your `filelist` is empty, re-check what your working directory is.

**Note:** use something like

```r
setwd("/Users/username/courses/mie1626/miniproj2/set-a/")
```

to set your working directory while working on the project draft
in an R file. When you are ready to put your work in an Rmd file,
use both the above line and something like

```r
library(knitr)
opts_knit$set(root.dir = "/Users/username/courses/mie1626/miniproj2/set-a/")
```

in the setup chunk for your `Rmd` file.

```r
filelist = list.files(pattern = ".*.txt")
patient.dat = lapply(filelist, function(x) read.csv(x, header = TRUE, stringsAsFactors = FALSE))
```

We want the data to be read from text files and assembled into a
dataframe. To do so, please run the following code, which will
first define a function that reads in a single patient data text
file, and then runs that function on all the files and assembles
the outputs into a single dataframe.

**Look at the function `comp.patient` and explain what it is doing
in your report. Look at the first row of `allpat.dat` and at the
first element of `filelist`, and explain precisely how the `Age`
and `Temp` columns were computed. Reproduce the computation for
`Temp` in your report and make sure that the numbers match.** To
reproduce the computation, look up the relevant numbers in the
relevant txt file, and then enter them in your Rmd file and
perform the computation in R.

```r
get.mean.attr <- function(attr, pat.dat){
  mean(pat.dat$Value[pat.dat$Parameter == attr], na.rm = T)
}

comp.patient <- function(ind, dat){
  pat.dat <- dat[ind][[1]]
  pat.dat[pat.dat == -1.0] = NaN

  Urine     <- mean(pat.dat$Value[pat.dat$Parameter == "Urine"])
  HR        <- mean(pat.dat$Value[pat.dat$Parameter == "HR"])
  Temp      <- mean(pat.dat$Value[pat.dat$Parameter == "Temp"])
  age       <- pat.dat$Value[pat.dat$Parameter == "Age"]
  Gender    <- pat.dat$Value[pat.dat$Parameter == "Gender"]
  ICUtype   <- pat.dat$Value[pat.dat$Parameter == "ICUType"]
  height    <- pat.dat$Value[pat.dat$Parameter == "Height"]
  weight    <- mean(pat.dat$Value[pat.dat$Parameter == "Weight"])
  NIDiasABP <- mean(pat.dat$Value[pat.dat$Parameter == "NIDiasABP"])
  SysABP    <- mean(pat.dat$Value[pat.dat$Parameter == "SysABP"])
  DiasABP   <- mean(pat.dat$Value[pat.dat$Parameter == "DiasABP"])
  pH        <- mean(pat.dat$Value[pat.dat$Parameter == "pH"])
  PaCO2     <- mean(pat.dat$Value[pat.dat$Parameter == "PaCO2"])
  PaO2      <- mean(pat.dat$Value[pat.dat$Parameter == "PaO2"])
  Platelets <- mean(pat.dat$Value[pat.dat$Parameter == "Platelets"])
  MAP       <- mean(pat.dat$Value[pat.dat$Parameter == "MAP"])
  K         <- mean(pat.dat$Value[pat.dat$Parameter == "K"])
  Na        <- mean(pat.dat$Value[pat.dat$Parameter == "Na"])
  FiO2      <- mean(pat.dat$Value[pat.dat$Parameter == "FiO2"])
  GCS       <- mean(pat.dat$Value[pat.dat$Parameter == "GCS"])
  MechVent  <- mean(pat.dat$Value[pat.dat$Parameter == "MechVent"])
  ID        <- pat.dat$Value[1]

  data.frame(ID, age, Gender, height, ICUtype, weight, Urine, HR, Temp,
             NIDiasABP, SysABP, DiasABP, pH, PaCO2, PaO2, Platelets, MAP,
             K, Na, FiO2, GCS, MechVent)
}

### run comp.patient on all files
numpats <- 4000
df <- lapply(c(1:numpats), FUN = comp.patient, dat = patient.dat)

# assemble into a single dataframe
allpat.dat <- Reduce(function(x, y) rbind(x, y), df)
```

We read in an additional file --- the outcome of the patients
whose data was loaded above. We append these outcomes to the
original dataframe and remove values that are -1, inf, -inf, or
NaN, and replace them with the average value across all patients.

```r
outcome.dat <- read.csv("Outcomes-a.txt")
outcome.dat[outcome.dat == -1] = NaN

# Append the outcomes (different files)
full.dat <- cbind(allpat.dat, outcome.dat[, 2:ncol(outcome.dat)])
full.dat[full.dat == Inf]  = NaN
full.dat[full.dat == -Inf] = NaN

# Set everything that's NaN to the mean of that column:
for (i in 1:ncol(full.dat)) {
  full.dat[is.na(full.dat[, i]), i] <- mean(full.dat[, i], na.rm = TRUE)
}
```



Part 2: Run logistic regression (10 pts)
----------------------------------------

Divide your data into training, validation, and test sets.

Use the features `HR`, `Gender`, `age`, `temperature`, `weight`,
`height`, `PaO2`, and `PaCO2`, and run a logistic regression
model. Is your performance (on both the training and the
validation sets) better than the base rate?



Part 3: ROC curve (10 pts)
--------------------------

Write a function that, for a given threshold, calculates both the
False Positive Rate (proportion of non-deaths identified as
deaths) and True Positive Rate (proportion of deaths correctly
identified as such) for your regression model.

For 100 threshold values equally spaced from 0 to 1, plot the True
Positive Rate vs. the False Positive Rate. Use the validation set.

This plot is known as an ROC curve.



Part 4: Interpreting the ROC curve (5 pts)
------------------------------------------

Using the plot generated in Part 3, what is the False Positive
Rate associated with correctly identifying 90% of patients at risk
for death in the ICU? Why might a high false positive rate be
appropriate in this setting? You can read the answer off the ROC
curve plot.



Part 5(a): Modelling Doctors' Decision-Making (15 pts)
------------------------------------------------------

For this part, produce a short report that answers all the
questions below. Include R code that produces the numbers that you
need.

At the beginning of their shift, a doctor reviews their patients'
charts, and decides what intervention is needed for each patient.
In the following Parts, we will be trying to improve this process.
We will consider a simplified version of what is going on. Suppose
that if the doctor intervenes correctly, the patient will not die;
suppose that the doctor has 60 minutes to look through 25 patient
charts; and suppose that the probability of missing the correct
treatment if the doctor spends $t$ minutes on reviewing a file is

$$ P(\text{fail}) = \exp(-t^2/100). $$

If the doctor reviews all the files, spends an equal amount of
time on each chart, and there are 10 patients who will die without
the correct intervention, how many patients are expected to die,
if the doctor intervenes when they see that that's needed? What is
the percentage of patients who are expected to die, out of 25?

Suppose now that the doctor is looking through all the patient
charts in the validation set. They would have proportionately more
time: $(N/25) \times 60$ minutes in total (where $N$ is the total
number of patients in the set). How many patients would be
expected to die, if the doctor intervenes correctly when they know
they should do that?

Now, suppose that the doctor only reviews the files of patients
for whom the model outputs a probability of greater than $20\%$.
This would give the doctor more time to look through each file,
but the doctor would never be able to intervene in the cases of
patients for whom the output is $20\%$ or smaller. How many
patients would be expected to die?



Part 5(b): Modelling Doctors' Decision-Making (15 pts)
------------------------------------------------------

In this Part, you will explore the policy implications of using
our model in an understaffed hospital.

Suppose that we are considering a policy of only reviewing the
files of patients whose probability of death is above a threshold
`thr`. Each chart would be given an equal amount of time, and the
total amount of time will be $(N/25) \times 60$.

Using the model from 5(a), plot the total number of expected
deaths under the policy vs. the threshold. Using the plot, what is
the best threshold to use that would minimize the number of
deaths?

You should compute the expected number of deaths for the
thresholds `seq(0, 1, 0.001)`.

Use the validation set.



Part 5(c): Modelling Doctors' Decision-Making (5 pts)
-----------------------------------------------------

On the test set, compare the total number of expected deaths under
the best policy that was selected in 5(b) to reviewing each
patient's file. In relative terms (i.e., as a percentage), how
many lives would be saved, if the assumptions underlying our
simulation are accurate?



Part 6: Critiquing the Simulation (5 pts)
-----------------------------------------

We made a number of assumptions when we tried to assess the impact
of using our model. Critique those assumptions.



Part 7: Linear Regression (10 pts)
----------------------------------

Formulate a hypothesis about the data (in a way that makes it so
that the model assumptions are satisfied). Check the model
assumptions, test a null hypothesis, and state your conclusions.
