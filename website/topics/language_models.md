---
title: "How Large Language Models Work"
output:
  html_document: default
  pdf_document: default
---



This is a from-first-principles sketch of how models like Claude and ChatGPT
work. It won't be the complete story, but it builds directly on the
[neural networks](neural_networks.html) notes — and it turns out you already have
almost everything you need.

The one new problem is **language**. For the face network, an input was a
fixed-size vector of pixel brightnesses: even a big image resizes to a fixed
number of pixels. Language isn't like that. A prompt is a variable number of
**words**, and words aren't numbers, let alone fixed-dimensional vectors. Two
tricks fix this, and that's essentially all a language model is.

## What an (autoregressive) language model does

An **autoregressive** language model does one thing: given the previous context
(the **prompt**), predict the **next word**.

That's it. To generate text you do it in a loop:

```
prompt                       -> predict word₁
prompt, word₁                -> predict word₂
prompt, word₁, word₂         -> predict word₃
...
```

Each predicted word is appended to the context and fed back in. That loop, one
word at a time, is what's happening when Claude or ChatGPT writes you a paragraph.
(In practice the unit is a **subword** token, not a whole word, but the idea is
identical.)

**"Predict" in what sense?** The same sense as the image classifier. You train it
on a training set built from ordinary text: chop text into (context → next word)
pairs.

```
"To be or"          -> "not"
"To be or not"      -> "to"
"To be or not to"   -> "be"
...
```

At **training** time you already know the answer and adjust the coefficients so
the model gets it right (exactly like showing the face network a labelled photo).
At **generation** time you run the same machine on a context whose continuation you
*don't* know. "Prediction" is the training verb; generation is prediction with the
answer hidden.

## Trick 1: words become vectors (embeddings)

Pick a fixed dimension — say 2000 — and map every word to a 2000-dimensional
vector, its **embedding**. `dog` is some 2000-vector, `hat` is another, and so on.

Where do the vectors come from? You don't write them by hand. They are just more
**parameters**: the model starts with random vectors and, while training to
predict the next word, adjusts them along with everything else. "Figure out
whatever mapping from words to vectors makes next-word prediction work best."

Once each word is a fixed-length vector, a variable-length prompt still has to
become one fixed-length vector. The simplest recipe: **average the word vectors**
in the context, then feed that average into a network whose outputs $z_1, \ldots,
z_V$ score each word in the vocabulary — predict the word with the highest score,
exactly the multinomial-logistic setup from the face network (with $V$ = vocabulary
size in place of 6 faces). Averaging is crude but really works; the modern
architecture (below) replaces it with something better.

### The famous side effect: word arithmetic

When you learn embeddings *only* to predict well, something remarkable falls out
for free: directions in the vector space become **meaningful**. The step from
`man` to `woman` is roughly the same vector as the step from `king` to `queen`, so

$$\text{vec}(\text{king}) - \text{vec}(\text{man}) + \text{vec}(\text{woman})
\approx \text{vec}(\text{queen}).$$

Nobody built that in. It **emerges** because vectors that are good for prediction
end up placing analogous words in analogous positions. (It's not fully understood,
and it doesn't always work — but it works often enough to be startling.) To
actually run it you take the arithmetic result and find the vocabulary word whose
embedding is closest to it — the same cosine/dot-product nearest-neighbour search
from the [neural networks](neural_networks.html) notes.

## Trick 2: the transformer (handling variable length properly)

Averaging throws away word order and structure. The real architecture is the
**transformer**. The shape is familiar — layers of hidden units — with one twist
to cope with variable length.

- Convert each of the $K$ prompt words to its embedding vector.
- Stack **layers**, each the *same size* as the input (one hidden vector per input
  position). Transform embeddings → hidden layer → hidden layer → ... — hence
  "trans**former**."
- Read the final layer's output as a fixed-dimensional vector and finish with the
  ordinary output layer ($z_1, \ldots, z_V$), picking the largest — just like the
  face network.

The twist: with a variable number of words you can't have a *fixed* set of
connection weights between layers. So the transformer **computes the connection
weights on the fly** — the weight linking position $i$ to position $j$ is itself a
*function of the vectors at $i$ and $j$*. That data-dependent wiring (this is
**attention**) is the whole trick; everything else is the neural network you
already know. This is the **decoder transformer** architecture that essentially
everyone uses.

The training set is, again, just text — potentially all the text on the internet,
cut into chunks — turned into (context → next word) pairs.

## What makes chatbots useful: ICL, chain-of-thought, tools, agents

Pure next-word prediction "works but often produces bad outputs." A few
developments turned it into something useful.

- **In-context learning (few-shot).** If the prompt contains a few **worked
  examples**, the output gets much better — the model picks up the pattern from
  the prompt itself, no retraining. The surprising discovery (early 2020s): train
  it to use worked examples in *one* domain and it starts using them across *other*
  domains too. (This requires setting up training the right way, not just plain
  gradient descent.)
- **Chain-of-thought ("think step by step").** Because the model just continues
  text coherently, a prompt that says *think step by step* makes the continuation
  coherent with *following that instruction* — so it emits a first step, then a
  second, then a third: a logical chain instead of a blurted guess. Same reason a
  math teacher says "show your work": writing intermediate steps makes the final
  answer more likely to be right. This is now baked into the **system prompt**, so
  you rarely need to say it yourself.
- **Multi-hop reasoning is a weakness.** Predicting the next token is bad at tasks
  that need lots of lookahead in one shot — playing chess well, executing a chunk
  of code in your head. Chain-of-thought helps but doesn't cure it.
- **Tool use.** The fix for hard sub-tasks: train the model to emit special text
  that the surrounding program reads as an *instruction* — "run this Python", "do
  this search", "make this figure" — instead of guessing the answer. This was the
  big recent advance and is exactly what Claude Code does.
- **Agents.** An agent is an autoregressive model **run in a loop**: it predicts a
  plan, treats the whole running history as its new prompt, acts (often by running
  code via a tool), then plans again from the updated history. "Agentic" borrows
  the philosophical sense of *agency* — it emits text that *is* a plan and then
  continues as if executing it.

## Can prediction alone produce understanding?

A genuinely open, and fun, question — and one where the early confident "no" has
aged badly.

**The octopus test (Bender & Koller, 2020).** Two people on separate islands
converse by telegraph through an undersea cable. A hyper-intelligent octopus taps
the cable and learns to imitate the messages statistically. Could it *fool* one
person into thinking it's the other? The paper argues no: when a genuinely novel
situation arrives — "I'm being chased by a bear, I have a couple of sticks, what
do I do?" — the octopus has only ever seen word patterns, never a bear or a stick
(no **grounding** in meaning), so it can't help. They tested GPT-2 (2020) and it
indeed failed such prompts.

**The falsifiable slip.** In the appendix they predicted the argument rules out
addition too: GPT-2, asked to finish `3 + 5 =`, emits *a* number but the *wrong*
one, and they claimed this is "beyond the ability of any pure language model."
That's a testable claim — and it turned out false. GPT-3 and later do addition
well (up to a point: ~10-digit sums start failing, multiplication is harder,
division basically doesn't work without a tool). And it isn't memorisation —
models trained on data that provably excludes the specific answers still do it.

**Why might prediction alone get there?** An analogy from the history of
astronomy. Stars are "just inputs" — dots in the sky; we never touched one. Yet
astronomers, purely from observation, went geocentric → epicycles (which
predicted *superbly*) → Copernicus (physically truer but initially *worse* at
prediction) → **Kepler's ellipses** (simpler *and* better) → Newton → Einstein.
The engine was: predict the observations well while keeping the model **simple**
(Occam's razor). A neural network can be pushed the same way — fewer layers,
coefficients kept near zero, and other regularisers all pressure it toward simpler
models. So maybe, given enough data and the right pressure toward simplicity, a
predictor *could* recover the underlying structure — just as astronomers did from
dots of light. Or maybe it gets stuck on "epicycles" — a decent-but-wrong theory —
and needs impractically much data. It's genuinely unsettled; a claimed *proof* of
impossibility from a couple of years ago has itself been argued to be flawed.

## Summary

- An autoregressive LM predicts the next word/subword from the context, in a loop.
  Training data is ordinary text cut into (context → next word) pairs.
- **Trick 1:** map words to fixed-dimensional **embedding** vectors — themselves
  learned parameters. A side effect is meaningful **word arithmetic**
  (king − man + woman ≈ queen).
- **Trick 2:** the **transformer** handles variable-length input by computing its
  connection weights on the fly from the token vectors (**attention**); the rest
  is the neural network from before.
- **In-context learning**, **chain-of-thought**, **tool use**, and the
  **agent** loop are what make a next-word predictor genuinely useful.
- Whether prediction alone can yield real understanding (the **octopus test**) is
  open — but the confident early "no" underestimated it.

## References

- Bender & Koller (2020), "Climbing towards NLU: On Meaning, Form, and
  Understanding in the Age of Data" — the octopus thought experiment.
- Vaswani et al. (2017), "Attention Is All You Need" — the transformer.
- Mikolov et al. (2013) — word embeddings and the king/queen arithmetic.
- Builds on the [neural networks](neural_networks.html) notes (templates, the
  dot product, the multinomial-logistic output layer).
