
# Compile a package for woe32 on Linux (either x86-64 or x86-32)
# using MinGW Linux-hosted cross-compiler and wine (and libtool 2.2.x).

ifeq ($(strip $(PACKAGE)),)
	$(error PACKAGE is not set)
endif
ifeq ($(strip $(VERSION)),)
	$(error VERSION for $(PACKAGE) is not set)
endif

# Different distros call MinGW compiler in different ways
include mingw.conf

PREFIX ?= /opt/$(ARCH)

# If the package is re-configured, make will try rebuild everything,
# since the `config.h' file and friends have been re-generated. Use ccache(1)
# as a work around. N.B.: ccache is a *NIX
CCACHE ?= ccache

# Use MinGW toolchain
CC := $(CCACHE) $(ARCH)-gcc
CXX := $(CCACHE) $(ARCH)-g++
# XXX: libtool 2.2.x dislikes AS containing whitespace
# AS := $(CCACHE) $(ARCH)-as
AS := $(ARCH)-as
LD := $(ARCH)-ld
NM := $(ARCH)-nm
AR := $(ARCH)-ar
RANLIB := $(ARCH)-ranlib
DLLTOOL := $(ARCH)-dlltool
WINDRES := $(ARCH)-windres
OBJDUMP := $(ARCH)-objdump
STRIP := $(ARCH)-strip
export CC CXX AS LD NM AR RANLIB DLLTOOL WINDRES OBJDUMP STRIP

# We also need some *NIX tools (shell, make, TeX, etc.)
# XXX: libtool cross compilation with wine works only with bash
SHELL := /bin/bash
CONFIG_SHELL := /bin/bash
PATH := $(MINGW_PREFIX)/bin:/usr/local/bin:/bin:/usr/bin
export SHELL CONFIG_SHELL PATH

# Compile for generic x86_64 CPU
CFLAGS := -O2 -g -Wall -pipe
CXXFLAGS := $(CFLAGS)
CPPFLAGS :=
LDFLAGS :=
CPPFLAGS += -I$(DESTDIR)$(PREFIX)/include
LDFLAGS += -L$(DESTDIR)$(PREFIX)/lib
PKG_CONFIG_PATH := $(DESTDIR)$(PREFIX)/lib/pkgconfig
# XXX: In order to convince libtool to create a shared library one need to
# pass the `-no-undefined' switch. The most straightforward way is to append
# it to LDFLAGS. It should be noted that GCC has no idea what -no-undefined
# is. Older GCCs used to ignore unknown switches (which seems to be a good
# idea). However, recent versions of GCC bail out on any unknown switches,
# so passing `-no-undefined' via LDFLAGS won't work: configure will complain
# that `No working C compiler was found'. Hence we introduce EXTRA_LDFLAGS
# and pass to `make' only (which in turn passes it to libtool).
EXTRA_LDFLAGS :=
include $(PACKAGE)_cflags.mk
export CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH

SRCDIR := $(shell pwd)/../../$(PACKAGE)
BUILDDIR := $(shell pwd)/../../build-tree/build/$(PACKAGE)-$(VERSION)
STAMPDIR := $(shell pwd)/../../build-tree/stamps

# Classical cross-compilation
# XXX: configure script fails detect cross-compilation since we set up
# binfmt_misc to directly execute woe32 binaries (which is necessary for
# tests). So --host=... and --build=... arguments below *are* necessary.
# In order to find out politically correct for of the --build we need
# the config.guess script from libtool. However the package might put it into
# a different subdirectory, hence we need to parse configure.{ac,in} to
# find out where that directory is.
define configure_ac
$(SRCDIR)/configure$(if $(wildcard $(SRCDIR)/configure.ac),.ac,.in)
endef
ac_config_aux_dir_rx := 's/^AC_CONFIG_AUX_DIR([[]*\([^])]\+\)[]]*)[ \t]*$$/\1/p'
define ac_config_aux_dir
$(strip $(shell sed -n -e $(ac_config_aux_dir_rx) $(configure_ac)))
endef
define config_guess
$(SRCDIR)/$(if $(ac_config_aux_dir),$(ac_config_aux_dir)/,)config.guess
endef

define pkgconfig
$(strip $(shell set -e; export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
		pkg-config --define-variable=prefix=$(DESTDIR)$(PREFIX) $(1)))
endef


CONFIGURE := $(CONFIGURE_ENV) $(SHELL) $(SRCDIR)/configure \
	--host=$(ARCH) --build=$(shell $(config_guess)) \
	--enable-shared --disable-static --prefix=$(PREFIX) \
	$(CONFIGURE_ARGS)

CONFIG_STAMP := $(STAMPDIR)/config.$(PACKAGE)-$(VERSION).stamp
BUILD_STAMP := $(STAMPDIR)/build.$(PACKAGE)-$(VERSION).stamp
CHECK_STAMP := $(STAMPDIR)/check.$(PACKAGE)-$(VERSION).stamp
INSTALL_STAMP := $(STAMPDIR)/install.$(PACKAGE)-$(VERSION).stamp

all: install
config: $(CONFIG_STAMP)
build: $(BUILD_STAMP)
check: $(CHECK_STAMP)
install: $(INSTALL_STAMP)

CLEANFILES := $(INSTALL_STAMP) $(CHECK_STAMP) $(BUILD_STAMP) $(CONFIG_STAMP)
CLEANDIRS := $(BUILDDIR)
ALLCLEANFILES := $(CLEANFILES)
ALLCLEANDIRS := $(CLEANDIRS)

ifeq ($(strip $(BUILD_TOOL)),cmake)
include ../cmake_build.mk
else
include ../autotools_build.mk
endif

clean:
	-@echo [CLEAN] $(PACKAGE)
	-@rm -f $(CLEANFILES)
	-@rm -rf $(CLEANDIRS)

allclean:
	-@echo [ALLCLEAN] $(PACKAGE)
	-@rm -f $(ALLCLEANFILES)
	-@rm -rf $(ALLCLEANDIRS)

.PHONY: install check clean allclean
# disable parallel execution of rules in this file, but pass on -j ( and
# other flags) so package's own makefile can use parallel make 
.NOTPARALLEL:

