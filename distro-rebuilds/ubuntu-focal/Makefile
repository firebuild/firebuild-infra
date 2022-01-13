main-pkgs:
	chdist -d chdist-dir create focal http://archive.ubuntu.com/ubuntu focal main ; \
	chdist -d chdist-dir apt focal update && \
	awk '/^Package: / {print $$2}' chdist-dir/*/var/lib/apt/lists/*_source_Sources > $@

clean:
	rm -rf chdist-dir main-pkgs

.PHONY: clean
