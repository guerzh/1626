SRC := proposal.md
OUT := proposal.html
CSS := style.css

PANDOC_FLAGS := \
	--standalone \
	--mathjax=https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js \
	--css=$(CSS) \
	--metadata title="Course Project: Proposal" \
	--highlight-style=tango \
	--from markdown \
	--to html5

$(OUT): $(SRC) $(CSS) Makefile
	pandoc $(PANDOC_FLAGS) -o $(OUT) $(SRC)

.PHONY: clean view
clean:
	rm -f $(OUT)

view: $(OUT)
	xdg-open $(OUT) >/dev/null 2>&1 &
