# Updating the lecture notes — runbook

How to turn a lecture into topic notes on the course site, distilled from how we've been doing it. Follow this each time a new lecture is recorded.

## The core rule

**Notes must correspond to what was actually in the lecture.**

- Work from the **transcript** (`materials/transcripts/MayNNPartK.txt`). Keep close to the **language in the transcript** and in the **existing notes** — same voice, same examples, same emphasis.
- **Be comprehensive**: cover everything the lecture covered. Don't skip a worked example or a side point just because it's small.
- **Don't invent content that wasn't taught.** If a topic isn't in the transcript, don't write it up as if it were a lecture (e.g. we did *not* manufacture causal-inference notes for a lecture that never covered them). Flag forward-references instead of fabricating them.
- If the lecture gave a **simplified / intuition** version that differs from the **standard textbook treatment**, present *both*: lead with the lecture's version (faithful to what students heard), then add the standard version and **explain why they differ**. (See the Lady Tasting Tea section in `hypothesis_testing.Rmd`: lecture's independent-guess `2^8` intuition first, then Fisher's fixed-margin hypergeometric `C(8,4)=70` / `fisher.test`.)
- When notes describe a **real tool or library**, use its **actual interface** — verify against the source, don't guess. (e.g. `notopenai`: `from notopenai import NotOpenAI`, `CLIENT.chat.completions.create(...)`, `gpt-3.5-turbo` only — checked against the real `notopenai.zip` and the [vibe-coding lab](https://www.cs.toronto.edu/~guerzhoy/vibecoding/vibecoding.html), not made up.)

## Code & style conventions in `.Rmd`

- **Pipe:** always `%>%`, never `|>` (source, rendered `.md`, and `.html`).
- **Executable stats content:** live ` ```{r} ` chunks — the render runs them, so the output and figures are real.
- **Workshop / can't-run code** (Python, API calls, agent prompts, shell): plain fenced ` ```python ` / ` ``` ` blocks (not executed), matching `agentic_scraping.Rmd` and `llm_text_analysis.Rmd`. Use `eval=FALSE` only if you want a real R chunk shown but not run.
- **Math:** MathJax via CDN. `render_topics.R` passes `--mathjax=https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js`. Do **not** let pandoc fall back to bare `--mathjax` (it points at a local `/usr/share/...` path that 404s in the browser).
- Match the existing YAML front-matter (`title:`, `output: html_document/pdf_document`) and the `knitr::opts_chunk$set(echo = TRUE, ...)` setup chunk.
- Big external datasets used by a topic are cached under `website/topics/data/` (e.g. `srrs2.dat` for the radon example) so renders are reproducible offline.

## Rendering

From `website/`:

```bash
Rscript render_topics.R <topic>        # render one topic, e.g. hierarchical_models
Rscript render_topics.R                 # render all topics
```

This knits each `topics/<topic>.Rmd` → `.md` → standalone `.html` (with the shared navbar/header/footer from `style/`). After rendering, check the `.md` for `## Error` lines — a clean render has none.

## Calendar, recordings, materials

- **Calendar** (`website/lectures.html`): one `<tr>` per week. Each topic links to both the `.html` and the `.Rmd`. Keep the per-topic one-line description in sync with the notes.
- **YouTube recordings:** source of truth is `materials/transcripts/youtubelinks.txt`. On the calendar, **strip tracking/timestamp params** — use clean `watch?v=<id>` only (no `&t=`, no `&pp=`).
- **Reference materials** (SML201 / SML310, etc.): URLs live in `materials/urls.txt`; mirror them into `materials/201s20/…`, `materials/310f19/…`. They're an archive — the live site links the instructor's canonical pages, not these local copies.
- `materials/` lives at the repo root (siblings: `201s26`-style term dir, historical dirs, `transcripts/`). The **served** PDFs (syllabus, test reference sheet) are the copies under `website/materials/1626s26/`.

## Publish

From the repo root:

```bash
./deploy.sh -n      # dry run — show what would change
./deploy.sh         # rsync website/ → guerzhoy@www.cs.toronto.edu:public_html/1626s26
```

`deploy.sh` never deletes remote files unless you pass `--delete` (preview with `-n --delete` first). Published at https://www.cs.toronto.edu/~guerzhoy/1626s26/.

## Quick checklist for a new lecture

1. Read `materials/transcripts/MayNNPart{1,2}.txt`; list the topics covered.
2. For each topic: update an existing `.Rmd` or add a new one — transcript-faithful, comprehensive, `%>%`, real interfaces.
3. Cache any new datasets under `topics/data/`.
4. `Rscript render_topics.R <topics>`; confirm 0 `## Error` and that math/figures render.
5. Add/extend the week row in `lectures.html`; link each topic's `.html` + `.Rmd`.
6. Add the recordings line from `youtubelinks.txt` (cleaned links).
7. Refresh any new `materials/urls.txt` entries.
8. `./deploy.sh -n` then `./deploy.sh`.
