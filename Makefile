#!/usr/bin/make -f

PACKAGES := gmp cln ginac
include versions.mk
include conf/mingw.conf
BUILD_DOCS ?= yes
DESTDIR := $(shell pwd)/build-tree/inst
TOPDIR := $(shell pwd)
export TOPDIR
PREFIX := /opt/$(ARCH)
BIN_TARBALL := $(TOPDIR)/ginac-$(ginac_VERSION)-$(ARCH).zip
MD5SUMS := $(BIN_TARBALL:%=%.md5)

# FIXME: makeinfo fails due to wrong grep call in all locales except C
LC_ALL := C
export LC_ALL

all: upload

upload: $(BIN_TARBALL) $(MD5SUMS)

GINAC_STAMP := build-tree/stamps/install.ginac-$(ginac_VERSION).stamp
GMP_STAMP := build-tree/stamps/install.gmp-$(gmp_VERSION).stamp

PACKAGES_STAMPS := $(GINAC_STAMP) $(GMP_STAMP)

$(BIN_TARBALL): $(PACKAGES_STAMPS)
	set -e ; \
	cd $(DESTDIR) && find $(patsubst /%,%,$(PREFIX)) -type f | zip --quiet $@ -@

$(BIN_TARBALL:%=%.md5): %.md5: %
	md5sum $< > $@.tmp
	mv $@.tmp $@

$(GINAC_STAMP): $(GMP_STAMP)
	$(MAKE) -I `pwd`/conf -C mk/ginac PACKAGE=ginac VERSION=$(ginac_VERSION) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)

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

cln: $(GINAC_STAMP)

gmp: $(GMP_STAMP)

.PHONY: packages.stamp clean all upload ginac cln gmp

.NOTPARALLEL:

