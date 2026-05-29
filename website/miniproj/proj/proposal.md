% Course Project: Proposal
% MIE 1626


Submission instructions
=======================
Submit a PDF (1 page or more) on Gradescope. One submission per team.



Overview
========

The course project is an open-ended data analysis. Two requirements
distinguish it from the mini-projects:

- You must **collect your own dataset.** Re-using an existing
  curated dataset (Kaggle, UCI, course repositories, etc.) is not
  permitted. Acceptable sources include scraping, surveys, public
  APIs, sensor logs, or merging public sources in a way that
  produces a genuinely new dataset.
- The deliverable includes an **interactive dashboard** (e.g., Shiny)
  in addition to the written report.

The proposal is a short document that lets us check that the
question is well-posed, the data can actually be collected, and the
planned methods are reasonable. You will receive feedback before
starting the project in earnest.



Section 1: Team and topic
-------------------------

State the team members and a one-sentence description of the
project topic.



Section 2: Question
-------------------

State the specific question your project will answer. A good
question is narrow enough to answer with the data you have, but
substantive enough that the answer is not obvious in advance.



Section 3: Data
---------------

Describe the dataset you will collect:

a. The source(s) and the collection method (scraping, API, survey,
   sensors, merging of public records, etc.).

b. Roughly how many observations and variables you expect, and what
   each row will represent.

c. Any access, licensing, terms-of-service, or ethics
   considerations.

d. A short justification of why the resulting dataset is *unique*
   --- i.e., not already available in curated form.



Section 4: Methods
------------------

Sketch the planned analysis. Name specific techniques (e.g.,
logistic regression, hierarchical model, bootstrap). If a model is
involved, write its form, e.g.

$$ Y^{(i)} = \beta_0 + \beta_1 X^{(i)} + \epsilon_i, \qquad \epsilon_i \sim \mathcal{N}(0, \sigma^2). $$

Explain in one or two sentences *why* this method matches the
question.

Note: there would not necessarily be a single "right" model, or a model at all. The point here is to start thinking conceretely about the project methods. This will not be graded harshly.



Section 5: Plan
---------------

A short timeline with milestones and who is responsible for each.
Two or three rows is enough.



Report quality
==============

The proposal is graded on clarity. In particular:

- The question is stated precisely, in one or two sentences.
- The data collection plan is concrete and feasible within the term.
- The proposed methods are named, not just gestured at.
