#!/bin/sh
# Sets up wine so we can run tests. 
# BIG RED WARNING: THIS SCRIPT DELETES YOUR ~/.wine WITHOUT ANY WARNINGS.
# I REALLY MEAN IT.
set -e

WINEPREFIX="$HOME/.wine"
rm -rf "${WINEPREFIX}"

# As a side effect this creates default ~/.wine
wineconsole --backend=curses cmd /c exit >/dev/null 2>&1
# XXX: wine exits too early
while [ ! -f "${WINEPREFIX}/system.reg" ]; do
	echo "`basename $0`: waiting for ${WINEPREFIX}/system.reg"
	sleep 1
done

if ! grep -q -e '^["]PATH["]=.*;X:\\\\bin' "${WINEPREFIX}/system.reg"; then
	echo "Setting up PATH for wine"
	sed -i -e '/^["]PATH["]=/ { s/["]$/;Y:\\\\bin;X:\\\\bin"/ ; }' "${WINEPREFIX}/system.reg"
fi

if [ -z "${DESTDIR}" ]; then
	DESTDIR="`pwd`/build-tree/inst/all"
fi

if [ -z "${prefix}" ]; then
	prefix=/opt/ginac
fi

ln -s "${DESTDIR}${prefix}" "${WINEPREFIX}/dosdevices/x:"

mingw_conf=`dirname $0`/conf/mingw.conf
if [ -r "${mingw_conf}" ]; then
	MINGW_PREFIX="$(sed -n -e 's/^MINGW_PREFIX[ \t]*[:]*[=][ \t]*\(.*\)$/\1/p' ${mingw_conf})"
fi
if [ -z "$MINGW_PREFIX" ]; then
	MINGW_PREFIX="/usr/local/mingw-w64"
fi

ln -s "${MINGW_PREFIX}" "${WINEPREFIX}/dosdevices/y:"

