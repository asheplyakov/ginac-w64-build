
$(CONFIG_STAMP):
	set -e; unset CONFIG_SITE ; \
	mkdir -p $(BUILDDIR); cd $(BUILDDIR); \
	$(CONFIGURE)
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	touch $@

$(BUILD_STAMP): $(CONFIG_STAMP)
	$(MAKE) -C $(BUILDDIR) LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	if [ x$(strip $(BUILD_DOCS)) != 'xno' ]; then $(MAKE) -C $(BUILDDIR) pdf; fi
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	touch $@

$(CHECK_STAMP): $(BUILD_STAMP)
	$(MAKE) -C $(BUILDDIR) check LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	touch $@

do_extra_install := : #
-include $(PACKAGE)_extra_build.mk

define do_install_real
set -e ; \
$(MAKE) -C $(BUILDDIR) install$(1) DESTDIR=$(2)$(if $(1),.stripped,) prefix=$(3) ; \
if [ x$(strip $(BUILD_DOCS)) != 'xno' ]; then $(MAKE) -C $(BUILDDIR) install-pdf DESTDIR=$(2)$(if $(1),.stripped,) prefix=$(3) ; fi ; \
rm -rf $(2)$(if $(1),.stripped,)$(3)/share/info ; \
rm -rf $(2)$(if $(1),.stripped,)$(3)/share/man ; \
rm -rf $(2)$(if $(1),.stripped,)$(3)/info ; \
rm -rf $(2)$(if $(1),.stripped,)$(3)/man ; \
find $(2)$(if $(1),.stripped,)$(3) -type f -name '*.la' | xargs rm -f ; \
$(call do_extra_install,$(1),$(2),$(3))
endef
define do_install
$(call do_install_real,$(strip $(1)),$(strip $(2)),$(strip $(3)))
endef

define fixup_pc_files
find $(1) -type f -name '*.pc' | xargs --no-run-if-empty -n1 sed -i -e 's%^prefix=.*$$%prefix=$(2)%g'
endef

$(INSTALL_STAMP): $(CHECK_STAMP) $(EXTRA_INSTALLS)
	$(call do_install,,$(DESTDIR),$(PREFIX))
	$(call fixup_pc_files,$(DESTDIR),$(PREFIX))
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	touch $@


