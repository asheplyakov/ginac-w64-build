#!/usr/bin/make -f

PACKAGES := gmp cln ginac
include versions.mk
include conf/mingw.conf
CONFIGURES := cln/configure ginac/configure
DESTDIR := $(shell pwd)/build-tree/inst
TOPDIR := $(shell pwd)
export TOPDIR
PREFIX := /opt/$(ARCH)/ginac
BIN_TARBALL := upload/ginac-$(ginac_VERSION)-cln-$(cln_VERSION)-gmp-$(gmp_VERSION)-$(ARCH).tar.bz2
$(info BIN_TARBALL = $(BIN_TARBALL))
RTFM := $(addprefix upload/,index.html vargs.css)
MD5SUMS := $(BIN_TARBALL:%=%.md5)

# FIXME: makeinfo fails due to wrong grep call in all locales except C
LC_ALL := C
export LC_ALL

all: upload

upload: $(BIN_TARBALL) $(MD5SUMS) $(RTFM)

upload/index.html: doc/readme.html.x doc/readme.py
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	( cd doc; ./readme.py $(ginac_VERSION) $(cln_VERSION) $(gmp_VERSION) ) > $@.tmp
	mv $@.tmp $@

upload/vargs.css: doc/vargs.css
	cp -a $< $@

$(CONFIGURES): %/configure:
	cd $(dir $@); autoreconf -iv

PACKAGES_STAMP := build-tree/stamps/packages.stamp

$(BIN_TARBALL): $(PACKAGES_STAMP)
	tar -cjf $@ -C build-tree/inst/all $(patsubst /%,%,$(PREFIX))

$(BIN_TARBALL:%=%.md5): %.md5: %
	md5sum $< > $@.tmp
	mv $@.tmp $@

$(PACKAGES_STAMP): $(CONFIGURES)
	$(MAKE) -I `pwd`/conf -C mk/gmp PACKAGE=gmp VERSION=$(gmp_VERSION) PREFIX=$(PREFIX)
	$(MAKE) -I `pwd`/conf -C mk/cln PACKAGE=cln VERSION=$(cln_VERSION) PREFIX=$(PREFIX)
	$(MAKE) -I `pwd`/conf -C mk/ginac PACKAGE=ginac VERSION=$(ginac_VERSION) PREFIX=$(PREFIX)
	touch $@

clean:
	-@echo CLEAN build-tree; rm -rf build-tree

allclean:
	-@echo CLEAN build-tree; rm -rf build-tree
	-@echo CLEAN cln; cd cln; git clean -d -f
	-@echo CLEAN ginac; cd ginac; git clean -d -f

.PHONY: packages.stamp clean all upload

.NOTPARALLEL:

