
# Sometimes we need to compile and run binaries during the build
HOST_CC := $(shell pwd)/hostcc-gcc
CPPFLAGS := -D__USE_MINGW_ANSI_STDIO
export HOST_CC

