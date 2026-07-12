---
title: "Neural Networks"
output:
  html_document: default
  pdf_document: default
---



Artificial neural networks are the models behind most of what people mean by "AI"
today. They are particularly useful on large, high-dimensional data — images,
video, audio, text. We'll build them up as a **statistical model** (something in
the same family as linear and logistic regression) and also gesture at the
**biological inspiration** that gives them their name.

The plan: start from the simplest possible classifier (nearest neighbour), see
that logistic regression is already a tiny neural network, and then add a
*hidden layer* to get a real one. Face recognition is the running example.

## Supervised learning, one more time

Everything in this course that predicts a label has had the same shape. You have
a **training set** of input–output pairs

$$(x^{(1)}, y^{(1)}), \; (x^{(2)}, y^{(2)}), \; \ldots$$

and a function $f_\theta$ with some coefficients $\theta$. You choose $\theta$ so
that $f_\theta(x^{(i)}) \approx y^{(i)}$ on the training set, and you *hope* that
the same $\theta$ predicts well on new, unseen data (the test set).

This is worth pausing on, because it is genuinely strange that it works. In an
intro programming course, "write some code, see that it's a bit wrong, tweak it,
see if it's better" is a terrible way to write a program — you usually just break
it in a new way. In machine learning that loop is exactly the method: guess
$\theta$, measure the error on the training set, nudge $\theta$ in a direction
that lowers the error, repeat. Eventually you land on a good $\theta$. So far we
have found coefficients with `lm` and `glm`; neural networks are fit with an
algorithm called **gradient descent**, which we won't cover — the point is only
that finding good coefficients is possible.

## The running example: recognising faces

Say you have photographs, each labelled with whose face it is, and you want to
identify new photos. How does a computer "see" a photo?

A grayscale image is a grid of pixels, each with a **brightness** — often an
integer from 0 (black) to 255 (white). Stack the rows end to end and you get a
**vector**: a $64 \times 64$ image becomes a vector of $64 \times 64 = 4096$
numbers. A colour image is the same idea with three numbers (red, green, blue)
per pixel; think grayscale for now.

So an image *is* a point in a high-dimensional space, and "these two photos look
alike" should mean "these two vectors are close." That single idea carries us all
the way to neural networks.

## One-nearest-neighbour

The simplest classifier there is. Keep the whole training set around. To label a
new image, find the *single* training image it looks most like, and copy that
image's label.

That's it. If the new photo is closest to a training photo of Paul, you guess
Paul.

To make "looks most like" precise we need a way to compare two vectors.

### Comparing vectors: distance vs. angle

The obvious measure is **Euclidean distance** — the straight-line distance
between the two endpoints:

$$d(a, b) = \sqrt{\sum_j (a_j - b_j)^2}.$$

For images this has a nasty flaw. Take an image, multiply every pixel by 0.5. It
is the *same picture*, just darker — visually the same face — but every
coordinate has moved halfway toward the origin (all-black), so the Euclidean
distance from the original can be large. Distance is polluted by overall
brightness.

**Cosine similarity** fixes this by looking at the *angle* between the vectors
instead of their endpoints. Two vectors that point the same way have angle 0
regardless of length:

$$\cos\theta = \frac{a \cdot b}{\lVert a \rVert \, \lVert b \rVert},
\qquad a \cdot b = \sum_j a_j b_j.$$

The numerator $a \cdot b$ is the **dot product**. The denominator divides out the
magnitudes, so scaling an image up or down (changing its overall brightness)
doesn't change the cosine. If all your images happen to have roughly the same
average brightness — the same magnitude — you can even skip the denominator and
just rank by the dot product: **large dot product = similar.**

Let's see the brightness problem directly. Two little "images" as vectors:


``` r
a <- c(10, 200, 50, 180)   # some image
b <- a * 0.5               # the SAME image, half as bright

euclidean <- function(u, v) sqrt(sum((u - v)^2))
cosine    <- function(u, v) sum(u * v) / (sqrt(sum(u^2)) * sqrt(sum(v^2)))

euclidean(a, b)   # large, even though it's the same picture
```

```
## [1] 136.9306
```

``` r
cosine(a, b)      # exactly 1: same direction, angle 0
```

```
## [1] 1
```

Euclidean distance calls the darker copy "far"; cosine similarity correctly calls
it identical.

### 1-NN in code

A tiny, honest version of the whole algorithm. Four 3×3 "images" (flattened to
length-9 vectors) as the training set, one new image to classify:


``` r
# Training "images": each row is a flattened 3x3 grayscale grid.
train_imgs <- rbind(
  vertical  = c(0,9,0, 0,9,0, 0,9,0),   # a vertical stroke
  horizontal= c(0,0,0, 9,9,9, 0,0,0),   # a horizontal stroke
  diagonal  = c(9,0,0, 0,9,0, 0,0,9)    # a diagonal stroke
)
labels <- rownames(train_imgs)

new_img <- c(0,8,0, 0,7,0, 1,9,0)       # looks like a vertical stroke

# Score the new image against each training image by cosine similarity,
# then copy the label of the best match.
sims <- apply(train_imgs, 1, function(row) cosine(row, new_img))
sims
```

```
##   vertical horizontal   diagonal 
##  0.9922779  0.2894144  0.2894144
```

``` r
labels[which.max(sims)]
```

```
## [1] "vertical"
```

The new image matches the vertical template best, so 1-NN calls it `vertical`.
Nearest-neighbour is dead simple and surprisingly hard to beat, but it has to
store and search the entire training set, and raw pixel similarity is a crude
notion of "looks alike." Neural networks *learn* a better notion.

## Logistic regression is a one-layer network

Now suppose there are six people to recognise. Here is the simplest network — it
is exactly **multinomial logistic regression** (logistic regression with more
than two classes).

Plug in the image $x = (x_1, \ldots, x_{4096})$. For each person $k$ compute a
score

$$z_k = \sigma\!\Big(\sum_j w_{kj}\, x_j + b_k\Big),$$

one weight $w_{kj}$ per pixel per person, squashed by the sigmoid $\sigma$ from
the [logistic regression](logistic_regression.html) notes. You get one $z_k$ per
possible name. In a picture:

```
 x1 ─┐
 x2 ─┼─► z1   (score for person 1)
  .  ├─► z2   (score for person 2)
  .  │   ...
x4096┴─► z6   (score for person 6)
```

Each arrow is a weight $w_{kj}$. We choose all the weights $W$ and biases $b$ so
that, on the training set, plugging in a photo of person 1 makes $z_1$ high and
the other scores low; plugging in person 6 makes $z_6$ high; and so on — just
like `glm` finds coefficients, only there are a lot more of them. To classify a
new photo, compute all six scores and report **whichever $z_k$ is largest.**

### The weights are templates

Here's the interpretation that makes the rest of the lecture click. The score for
person $k$ is $\sigma(w_k \cdot x + b_k)$ — it is large exactly when the dot
product $w_k \cdot x$ is large, i.e. when the image $x$ points in the same
direction as the weight vector $w_k$. So $w_k$ acts as a **template** for person
$k$: the network says "person $k$" when the input looks like person $k$'s
template, measured by the same dot product we used for nearest-neighbour.

If that story is right, we should be able to *see* it. Take a trained network,
pull out the weights $w_k$ that compute each person's score, reshape that length-
4096 vector back into a $64 \times 64$ grid, and look at it. What you get are
ghostly, blurry faces — you can squint and see a face-like blob, but no
individual is sharp. One template per person is simply too few: a single template
can't cover you facing left, facing right, smiling, in shadow. It "kind of works
but kind of not."

(Our eyes over-cooperate here — humans see faces in clouds and burnt toast — so
be a little skeptical of how face-like the blobs look.)

## Adding a hidden layer: a real neural network

The fix: allow **many** templates, not just one per person. That's a hidden
layer.

Before computing the six output scores, compute an intermediate layer of $K$
values $h_1, \ldots, h_K$ — the **hidden layer** — each one its own template
match:

$$h_m = \sigma\!\Big(\sum_j w^{(1)}_{mj}\, x_j + b^{(1)}_m\Big),
\qquad
z_k = \sigma\!\Big(\sum_m w^{(2)}_{km}\, h_m + b^{(2)}_k\Big).$$

In a picture, with the hidden layer in the middle:

```
 x1 ─┐        ┌─► h1 ─┐
 x2 ─┼──────► ┤   h2  ├──────► z1
  .  │        │   ..  │        z2
  .  │        └─► hK ─┘        ...
x4096┘                        z6
    inputs     hidden          outputs
   (pixels)  (templates)      (names)
```

Read it the same way. Each hidden unit $h_m$ is a template compared against the
raw image; the outputs $z_k$ are then computed from *how well the image matched
each of the $K$ templates*, rather than directly from the pixels. With, say,
$K = 200$ hidden units you have 200 templates to spread across all the poses and
lighting conditions of all six people.

Visualise the hidden templates — reshape each $w^{(1)}_m$ back into an image — and
now they look strikingly like faces. Some are generic face-parts; some look like
one *specific* training photo. That second kind is the network **memorising**: it
sets a template equal to a hard training image so that $h_m$ lights up only for
that exact image, then reads the answer off that. Memorising training images
makes training accuracy excellent and says nothing about new photos — this is
[overfitting](cross_validation.html), and it is why we always judge a model on a
held-out set.

Everything is still "just a formula with coefficients we fit on the training
set." The template story is only an *interpretation* — but it's a good one, and
it holds up when you look at the learned weights.

## Going deeper: features of features

The one-hidden-layer picture — global templates, one comparison, done — is
true but simplified. Real **deep** networks stack many hidden layers:

$$x \to h^{(1)} \to h^{(2)} \to \cdots \to h^{(L)} \to z.$$

Two ways to read this:

- **Features of features.** A *feature* is any property of the input. Instead of
  hand-picking features (square footage, size of the yard), the network invents
  its own. The first layer can only match crude, *local* templates — "is this
  patch orange?", "is there an edge here?" The next layer combines those into
  bigger pieces — "is this the corner of an eye?" — the next into "is this a
  face?", and so on. Features built on features built on features.
- **A partially-specified program.** A network with nine hidden layers is like a
  nine-step computation whose steps aren't written by you but *learned*: compute
  $h^{(1)}$ from the pixels, $h^{(2)}$ from $h^{(1)}$, ..., output from
  $h^{(9)}$. Deep learning = learning the steps.

### What are the deeper units detecting?

For a first-layer unit we could reshape its weights into an image and look. A
*deeper* unit's inputs are the $h$'s, not pixels, so its weights don't form a
picture. So we borrow Hubel & Wiesel's trick (below): feed the network many
images and see **which inputs make the unit fire hardest** — those images *are*
its "preferred stimulus."

Do this for a network trained on **ImageNet** (the 1000-category, ~million-image
dataset that kicked off the deep-learning era in 2012) and a clean hierarchy
appears:

- **Early layer (≈3):** units fire for orange patches, yellow patches, simple
  edges and curves — low-level texture and colour.
- **Middle layer (≈4):** units fire for a specific dog's fur pattern, wheels,
  spirals — parts and motifs.
- **Late layer (≈5):** units fire for whole abstract objects — a unicycle, a
  particular breed of dog, "creepy eyes."

The deeper you go, the more abstract the concept. (Caveat: a "dog" unit hasn't
learned what dogs *are*; among only 1000 options, a few characteristic patches
are enough to bet "dog." Don't over-read it.) The same principle runs modern
image-understanding — paste a photo into an LLM and it will categorise it.

## The deep learning hypothesis

Why should stacking layers work so well? An argument due to Ilya Sutskever (a
co-founder of OpenAI). Distinguish two properties a model can have:

- **Powerful** — able to express complicated, multi-step computation. A
  programming language like Python is powerful: you can write an arbitrarily long
  program. A deep network is *also* powerful, in the "stepwise computation" sense
  above.
- **Learnable** — tunable to the right behaviour just by showing it
  input/output examples. Python is *not* learnable: you can't hand an interpreter
  some examples and have correct code fall out. A network *is* learnable: nudge
  the coefficients until the training outputs are right.

Deep networks are rare in being **both**. The hypothesis then rides on a fact
about the brain: humans do perceptual tasks — "dog / cat / unicycle" — in about a
tenth of a second. Neurons communicate by firing rate and can only fire on the
order of 100 times per second, so in 0.1 s a chain of neurons can be at most
~10 steps deep. If a person can do a task in that budget, a network ~10 layers
deep ought to be able to as well. It has held up: fast networks with modest depth
now classify objects, and even judge "shape" (position quality) in the board game
**Go** better than expert humans — who themselves judge it by fast intuition, not
explicit search.

## Why "neural"? The biological inspiration

The name is a metaphor, but not an empty one.

A neuron is a cell that, when stimulated enough, "fires" an electrical pulse that
in turn stimulates other neurons. The human brain has on the order of 100 billion
of them, and the idea is that cognition arises from neurons firing and triggering
each other in cascades.

The clearest evidence comes from the **visual cortex** — the brain region that
handles early vision. In a Nobel-winning experiment, Hubel and Wiesel recorded
from a single neuron in a cat's visual cortex while showing it patterns, and
could *hear* the neuron fire (as clicks) only for a specific stimulus — e.g. a
bar at one particular orientation, moving one particular way. There is, quite
literally, a neuron that fires for a diagonal edge and stays quiet for a
horizontal one.

Map that onto the network:

- The inputs $x_j$ are like light receptors on the **retina**: a bright pixel is
  a receptor firing.
- A hidden unit $h_m$ is like a **visual-cortex neuron**: it "fires" (is large)
  when the input matches its template — its preferred pattern.
- An output neuron somewhere "deeper" fires because a particular combination of
  hidden neurons fired — "this is person 3."

For early vision this picture is well supported; deeper in the brain, neurons do
respond to more abstract things, but general cognition is not understood — there
is no single neuron that lights up when someone says "neural network" to you. The
biology inspired the model; it is not a literal description of it.

## Summary

- Supervised learning: pick coefficients $\theta$ so $f_\theta$ fits the training
  set, and hope it generalises. Neural nets are fit by gradient descent instead
  of `lm`/`glm`, but it's the same idea.
- An image is a vector of pixel brightnesses. Compare images by **cosine
  similarity / dot product**, not raw Euclidean distance, which is thrown off by
  overall brightness.
- **1-nearest-neighbour**: label a new image by its closest training image.
- **Logistic regression = a zero-hidden-layer network**: one *template* (weight
  vector) per class; classify by the largest dot product. One template per person
  is too few.
- A **hidden layer** gives you many templates; outputs are computed from how well
  the image matches each template. Enough templates and the network can memorise
  training images — great training accuracy, possible overfitting.
- **Deep** networks stack layers, building *features of features*: early units
  detect edges and colours, deeper units whole objects. Inspect a deep unit by
  the images that make it fire hardest.
- The **deep learning hypothesis**: deep nets are both *powerful* and *learnable*,
  and anything a human does in ~0.1 s should fit in ~10 layers.
- "Neural" is a metaphor grounded in the visual cortex (Hubel & Wiesel): hidden
  units behave like feature-detecting neurons.

## References

- Hubel & Wiesel, receptive fields in the cat's visual cortex — the experiment
  behind the "edge-detector neuron" picture.
- The face-recognition templates example follows the instructor's
  [machine-learning course materials](https://www.cs.toronto.edu/~guerzhoy/).
- Connections back to [logistic regression](logistic_regression.html) (the
  sigmoid, the linear score) and [cross-validation](cross_validation.html)
  (why memorising the training set is a trap).
