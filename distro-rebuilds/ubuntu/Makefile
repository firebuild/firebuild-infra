
DIST ?= jammy

$(DIST)-main-pkgs-filtered: $(DIST)-main-pkgs
	egrep -v '(^linux|golang)' $<  > $@

$(DIST)-main-pkgs:
	chdist -d chdist-dir create $(DIST) http://archive.ubuntu.com/ubuntu $(DIST) main ; \
	chdist -d chdist-dir apt $(DIST) update && \
	awk '/^Package: / {print $$2}' chdist-dir/$(DIST)/var/lib/apt/lists/*_source_Sources > $@

clean:
	rm -rf chdist-dir *-main-pkgs *-main-pkgs-*

.PHONY: clean
