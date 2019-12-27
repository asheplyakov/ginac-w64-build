
$(CONFIG_STAMP):
	set -e; \
	mkdir -p $(BUILDDIR) && cd $(BUILDDIR); \
	cmake -DCMAKE_TOOLCHAIN_FILE=$(TOPDIR)/mk/$(ARCH)-toolchain.cmake \
	-D CMAKE_BUILD_TYPE=RelWithDebInfo \
	-D CMAKE_INSTALL_PREFIX=$(PREFIX) \
	$(SRCDIR)
	mkdir -p "$(dir $@)"
	touch $@

$(BUILD_STAMP): $(CONFIG_STAMP)
	$(MAKE) -C $(BUILDDIR) VERBOSE=1
	mkdir -p "$(dir $@)"
	touch $@

$(CHECK_STAMP): $(BUILD_STAMP)
	$(MAKE) -C $(BUILDDIR) check VERBOSE=1
	mkdir -p "$(dir $@)"
	touch $@

$(INSTALL_STAMP): $(CHECK_STAMP)
	$(MAKE) -C $(BUILDDIR) install DESTDIR=$(DESTDIR)
	mkdir -p "$(dir $@)"
	touch $@
