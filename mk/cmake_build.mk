
$(CONFIG_STAMP):
	set -e; \
	mkdir -p $(BUILDDIR) && cd $(BUILDDIR); \
	cmake \
	-DCMAKE_TOOLCHAIN_FILE=$(TOPDIR)/mk/$(ARCH)-toolchain.cmake \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
	-DCMAKE_INSTALL_PREFIX=$(PREFIX) \
	$(CONFIGURE_ARGS) \
	$(SRCDIR)
	mkdir -p "$(dir $@)"
	touch $@

$(BUILD_STAMP): $(CONFIG_STAMP)
	$(MAKE) -C $(BUILDDIR) VERBOSE=1
	mkdir -p "$(dir $@)"
	touch $@

$(CHECK_STAMP): $(BUILD_STAMP)
	$(MAKE) -C $(BUILDDIR) test_suite VERBOSE=1
	$(MAKE) -C $(BUILDDIR) test ARGS=-j`nproc`
	mkdir -p "$(dir $@)"
	touch $@

$(INSTALL_STAMP): $(CHECK_STAMP)
	$(MAKE) -C $(BUILDDIR) install DESTDIR=$(DESTDIR)
	mkdir -p "$(dir $@)"
	touch $@
