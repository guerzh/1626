#!/usr/bin/env Rscript
# Knit every .Rmd in topics/ to topics/*.html via knitr + pandoc.
#
# Usage:
#   Rscript render_topics.R              # render all .Rmd files
#   Rscript render_topics.R vectors      # render just topics/vectors.Rmd
#   Rscript render_topics.R foo bar      # render topics/foo.Rmd and topics/bar.Rmd
#
# This script does:
#   1. knit each .Rmd to a .md (R chunks evaluated, plots written to topics/figure-html/)
#   2. shell out to pandoc to turn the .md into a standalone .html with MathJax
#
# Requirements:
#   - R with the `knitr` package
#   - the pandoc command on PATH
#   - data packages used by the Rmds (install once):
#       install.packages(c("ggplot2","dplyr","tidyr",
#                          "gapminder","babynames","titanic","Sleuth3"),
#                        lib = "~/R/library")

.libPaths(c("~/R/library", .libPaths()))

if (!requireNamespace("knitr", quietly = TRUE)) {
  stop("Install the 'knitr' package first.")
}
if (Sys.which("pandoc") == "") {
  stop("Could not find 'pandoc' on PATH.")
}

topics_dir <- "topics"
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  files <- list.files(topics_dir, pattern = "\\.Rmd$", full.names = TRUE)
} else {
  files <- file.path(topics_dir, paste0(args, ".Rmd"))
}

# Read the YAML title out of the file so the HTML <title> matches the Rmd
read_title <- function(path) {
  lines <- readLines(path, n = 30)
  if (length(lines) < 2 || lines[1] != "---") return(tools::file_path_sans_ext(basename(path)))
  for (l in lines[-1]) {
    if (l == "---") break
    if (startsWith(l, "title:")) {
      v <- sub("^title:\\s*", "", l)
      v <- gsub('^["\']|["\']$', "", v)
      return(v)
    }
  }
  tools::file_path_sans_ext(basename(path))
}

for (f in files) {
  if (!file.exists(f)) {
    message("Skipping (missing): ", f)
    next
  }
  message("Rendering: ", f)
  stub  <- tools::file_path_sans_ext(basename(f))
  md    <- file.path(topics_dir, paste0(stub, ".md"))
  html  <- file.path(topics_dir, paste0(stub, ".html"))
  title <- read_title(f)

  # knit creates figure files relative to its working dir; cd into topics/
  old_wd <- setwd(topics_dir)
  on.exit(setwd(old_wd), add = TRUE)
  tryCatch({
    # Give every Rmd its own figure subdirectory so chunks don't collide.
    knitr::opts_chunk$set(fig.path = paste0("figure-", stub, "/"))
    knitr::knit(basename(f), output = paste0(stub, ".md"), quiet = TRUE)
  }, error = function(e) message("  knit failed: ", conditionMessage(e)))
  setwd(old_wd)

  if (!file.exists(md)) next

  status <- system2(
    "pandoc",
    c(shQuote(md), "-o", shQuote(html),
      "--standalone",
      "--mathjax=https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js",
      "--include-in-header=style/topic_header.html",
      "--include-before-body=style/topic_navbar.html",
      "--include-after-body=style/topic_footer.html",
      "--metadata", shQuote(paste0("title=", title))),
    stdout = TRUE, stderr = TRUE
  )
  if (!is.null(attr(status, "status")) && attr(status, "status") != 0) {
    message("  pandoc failed for ", f)
  }
}

message("Done.")
