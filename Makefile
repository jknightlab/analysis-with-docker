PANDOC = pandoc
WEB_DIR = /usr/local/www/data/analysis-with-docker

PANDOC_COMMON = --standalone --smart --normalize --toc --highlight-style=tango
PANDOC_SLIDES = -t revealjs --toc-depth=1 -V toc-header="Overview" \
                -V theme="sydney" --template=include/templates/default.revealjs --slide-level=2

all: slides.html deploy
slides.html: analysis-with-docker.md include/templates/default.revealjs
	pandoc $(PANDOC_COMMON) $(PANDOC_SLIDES) -s analysis-with-docker.md -o slides.html

.PHONY: all deploy	
deploy: 
	mkdir -p $(WEB_DIR)
	cp slides.html $(WEB_DIR)/index.html
	cp -r reveal.js $(WEB_DIR)/
