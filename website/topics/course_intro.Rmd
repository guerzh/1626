---
title: "Course Introduction"
output:
  html_document: default
  pdf_document: default
---

## Course goals

This is the first time MIE1626 is offered in the summer. The official course description is very focused on statistical inference, and almost everyone here has done statistical inference in the past, at least for one course. We will give a somewhat different spin on it from what you usually see in the first course: in particular, we will try to do something that is more computational rather than kind of algebra-centric. There is also an opportunity to put together stuff that you may be seeing in other courses — what you get at data scientist job interviews — and try to make sure that you are able to answer the common job interview questions.

The second thing we will try to do is, to the extent it exists at all, to have you work with the modern data science workflow:

- **Agentic coding** for implementation.
- The cycle of acquire data → analyze data → present results → suggest something actionable about the data.

The third pillar is just coding. From the survey, some people have extensive coding experience; for the rest it is mostly an opportunity to consolidate some skills in R and Python, both in terms of practice and in terms of being able to read data-science code. This will hopefully work together with the statistical inference material — many of the examples, especially at the beginning of the course, will have to do not so much with processing data (although we will have that as well) but with doing inference.

## Course structure

- Approximately four assignments ("mini-projects"). These are just coding assignments. You can use AI, but you will be tested on the content of the assignments in the midterm (test 1) and the final (test 2).
- It is a compressed course: two three-hour sessions per week. That sounds like a lot but it is essentially two courses' worth of contact time.
- The mini-projects are not supposed to be onerous. They are probably easy to do with AI if you choose to work with AI, but you have to understand all the code because you are tested on it in the written tests.
- The tests are focused around what is in the lecture and especially what is in the mini-projects — you submit the project, you are supposed to know what is going on there.

The syllabus is at <https://www.cs.toronto.edu/~guerzhoy/1626s26/materials/1626s26/mie1626_syllabus.pdf>.

## Course project

This is a grad course, and there is only so much you can do with a theory course. The project is the main piece. We will scaffold it a little bit, but basically you get to choose what you work on. PhD students who have something data-science related in their research are welcome to work on whatever they want.

The shape of the project is:

- **Get a unique dataset.** For example, scrape Reddit. You can use any other source of data; it does have to be unique in some way. (Just downloading a dataset from Kaggle is not of interest.)
- **Some kind of statistical analysis** using at least one technique from the course, plus anything else you want.
- **Build some kind of dashboard.** Most of you have not done this; with `claude code` it is easy now. We will have a tutorial on how to do it. It is useful to have done it once and it is nice to have as a portfolio.
- **Something extra:** extra analysis, testing an interesting hypothesis, etc.

### Proposal

- ~1 page.
- Data source.
- A summary of at least 2 related papers.
- 1 or 2 people per project.

The proposal is worth 2%. The goal is for us to be on the same page; I might push back and have you resubmit, that is fine.

### Example of the kind of project I have in mind

Here is one paper that we published with one of my students, as a paradigmatic case (you do not have to do it this way).

In sociology there is the concept of a **culture of honor**. In some cultures more than others, people — men differently from women, but both in different ways — care about their honor, meaning about their kind of external reputation. In particular, focusing on men in many cultures, people sometimes really care about a reputation for standing up for themselves, sometimes violently.

In the 1990s there was a famous in-person experiment done at the University of Michigan. The hypothesis was that in the southern US, people tend to be more members of the culture of honor than in the north. They recruited students, told them that it was for a study, did not tell them what the study was, had the student walk down a hallway, then had one of the experimenters intentionally bump into the student in the hallway, curse at them, and walk away. They then led the student, who didn't know what was going on, into a room and measured their blood pressure and cortisol levels. Students from the south had higher blood pressure and higher cortisol levels after that incident than students from the north. (You are not allowed to do that experiment any more.)

We thought: can we get the same kind of experiment without risking a physical fight with anyone and without getting in trouble with the ethics review board? People argue and insult each other on the internet all the time, and one might imagine that if you are a member of a culture of honor, then you would be more motivated to retaliate against verbal aggression — if someone insults you on the internet, you want to retaliate against them because you want to uphold your reputation for someone who others do not want to mess with.

So we:

1. Scraped data from Reddit (post / comment threads).
2. Used an LLM to find which of the Reddit threads contained personal attacks.
3. Mined who retaliated and who did not retaliate to insults.
4. Geo-located the users. You cannot geo-locate all of them, but for some of them their usernames are the same usernames as what they use elsewhere on the internet, so you can look up their location.

Our hypothesis was that users located in the US south would be more likely to retaliate to insults than users not geo-located to the US south. Amazingly, it worked: notably, the aggression rate was roughly the same across users in the south and the non-south, but **retaliation** was actually higher for users in the south. The published paper is available [here](https://aclanthology.org/2024.sicon-1.1.pdf).

Obviously there is no expectation that you would necessarily get something publishable. If you do want to work with me on trying to publish something, that would be great as well. By no means is Reddit the only possible data source; you should come up with something that is unique. By default, Reddit has multiple sub-forums, you can come up with any topic of interest to you and there will be a forum about it on Reddit. We will also do a workshop on text mining. For any other dataset, by all means let me know and I will probably be OK with it.

## Course logistics

- The grades for this class are due in early July, but the course has been extended to a Y-course on request, so the final test will be in August and the project due date can be later. The schedule for the lectures and the mini-projects does not change.
- The mid-term test was set to Wednesday May 28 at 2pm, then moved to Thursday May 29 to give one more lecture of material.
- The exam is "open handout" rather than open book: the handout is given to you ahead of time. The handout includes the syntax for things like `filter` / `summarize` / `arrange` / `glm`, etc.
- Test 1 covers 70% mini-project material (mini-project 1 + mini-project 2) and 30% lecture material. Test 2 is similar.
- The goal is not to make you memorize syntax. There is no point to that.

## What we'll do today (May 6)

- Introduction to functional programming in R.
- If there is time, start talking about statistical inference using the tools from programming and R that we are about to learn.
