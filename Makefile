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

cln/configure:
	cd cln && ./autogen.sh && \
	chmod 755 build-aux/config.*

ginac/configure:
	cd ginac && autoreconf -iv

GINAC_STAMP := build-tree/stamps/install.ginac-$(ginac_VERSION).stamp
CLN_STAMP := build-tree/stamps/install.cln-$(cln_VERSION).stamp
GMP_STAMP := build-tree/stamps/install.gmp-$(gmp_VERSION).stamp

PACKAGES_STAMPS := $(GINAC_STAMP) $(CLN_STAMP) $(GMP_STAMP)

$(BIN_TARBALL): $(PACKAGES_STAMPS)
	tar -cjf $@ -C $(DESTDIR) $(patsubst /%,%,$(PREFIX))

$(BIN_TARBALL:%=%.md5): %.md5: %
	md5sum $< > $@.tmp
	mv $@.tmp $@

$(GINAC_STAMP): $(CLN_STAMP) ginac/configure
	$(MAKE) -I `pwd`/conf -C mk/ginac PACKAGE=ginac VERSION=$(ginac_VERSION) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)

$(CLN_STAMP): $(GMP_STAMP) cln/configure
	$(MAKE) -I `pwd`/conf -C mk/cln PACKAGE=cln VERSION=$(cln_VERSION) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)

$(GMP_STAMP):
	$(MAKE) -I `pwd`/conf -C mk/gmp PACKAGE=gmp VERSION=$(gmp_VERSION) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)

clean:
	-@echo CLEAN build-tree; rm -rf build-tree

allclean:
	-@echo CLEAN build-tree; rm -rf build-tree
	-@echo CLEAN cln; cd cln; git clean -d -f
	-@echo CLEAN ginac; cd ginac; git clean -d -f


print_destdir:
	@/bin/echo -n $(DESTDIR)

ginac: $(GINAC_STAMP)

cln: $(CLN_STAMP)

gmp: $(GMP_STAMP)

.PHONY: packages.stamp clean all upload ginac cln gmp

.NOTPARALLEL:

