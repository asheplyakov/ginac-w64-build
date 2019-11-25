#!/bin/sh
# Configure wine for running test suites of GMP, CLN, and GiNaC.
# BIG RED WARNING: THIS SCRIPT DELETES YOUR ~/.wine WITHOUT ANY WARNINGS.
# I REALLY MEAN IT.
set -e

export PATH=/opt/wine-stable/bin:$PATH

# Unfortunately binfmt-misc can use only default wineprefix, hence
# we re-create ~/.wine from from the scratch
WINEPREFIX="$HOME/.wine"
rm -rf "${WINEPREFIX}"

# Populate wineprefix.
# Problem #1:
#   wineboot requires an X display (to show progress bar), and this
#   script must be able to operate in a `headless` mode.
# Solution: Use the virtual framebuffer X server (Xvfb) and `xvfb-run`
#   to wrap `wineboot`
# Problem #2:
#   wineboot prompts to install a browser engine (gecko) and a C# runtime
#   (mono). It makes sense for most users who wish their windows apps to
#   `just work` with wine. However it's a waste of time and disk space
#   for running a handful of C++ console apps (test suites of GMP, CLN,
#   and GiNaC). Most importantly there's nobody to press OK/Cancel button.
# Solution: set
#   WINEDLLOVERRIDES='mscoree,mshtml='
#   to suppresses interactive prompts
# Problem #3:
#   wineboot exits too early, which causes xvfb-run to terminate the X
#   server instance, and background (wine) processes terminate with
#   the following X11 error:
#
#   XIO:  fatal IO error 11 (Resource temporarily unavailable) on X server ":99"
# Solution: keep the X server running until the (wine) registry file is produced
#   ($WINEPREFIX/system.reg)
xvfb-run /bin/sh -c "env WINEDLLOVERRIDES='mscoree,mshtml=' wineboot -u && while [ ! -f \"${WINEPREFIX}/system.reg\" ]; do echo \"waiting for ${WINEPREFIX}/system.reg\"; sleep 1; done"

# Make it possible to run the newly compiled binaries. This is necessary
# to run the test suite (`make check`) and unfriendly autoconf checks.
# Add directories with GCC/C++ runtime, GiNaC, CLN, and GMP DLLs to
# the default system (wine) `PATH`. This looks a bit crude, however
# there's no easy way to alter (wine) PATH via the command line, and
# `binfmt-misc` will run `wine /path/to.exe` anyway (that's the reason
# why this script wipes out the default wineprefix).
#
# The implementation is even more crude: edit wine registry with sed.
if ! grep -q -e '^["]PATH["]=.*;X:\\\\bin' "${WINEPREFIX}/system.reg"; then
	echo "Adjusting wine system PATH"
	sed -i -e '/^["]PATH["]=/ { s/["]$/;Y:\\\\;X:\\\\bin"/ ; }' "${WINEPREFIX}/system.reg"
fi

# check if wine is usable
wineconsole --backend=curses cmd /c exit >/dev/null 2>&1

# Map the staging directory (${DESTDIR}${PREFIX}) as the wine drive X:
if [ -z "${DESTDIR}" ]; then
	DESTDIR="$(make -f Makefile print_destdir)"
fi
if [ -z "${prefix}" ]; then
	prefix=/opt/ginac
fi
ln -s "${DESTDIR}${prefix}" "${WINEPREFIX}/dosdevices/x:"

# Map directory with GCC/C++ runtime DLLs as the wine drive Y:
mingw_conf=`dirname $0`/conf/mingw.conf
if [ -r "${mingw_conf}" ]; then
	ARCH="$(sed -n -e 's/^ARCH[ \t]*[:]*[=][ \t]*\(.*\)$/\1/p' ${mingw_conf})"
fi
if [ -z "$ARCH" ]; then
	ARCH="x86_64-w64-mingw32"
fi
libgcc_file="`${ARCH}-gcc -print-libgcc-file-name`"
runtime_dir="$(dirname $libgcc_file)"
ln -s "${runtime_dir}" "${WINEPREFIX}/dosdevices/y:"
