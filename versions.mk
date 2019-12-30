
gmp_VERSION := $(shell git --git-dir=gmp/.git describe --tags | sed -rne 's/^v([^ ]+)/\1/p')
cln_VERSION := $(shell git --git-dir=cln/.git describe --tags | sed -rne 's/^cln_([0-9]+)[-]([0-9]+)[-]([0-9]+)(.*)$$/\1.\2.\3\4/p')
ginac_VERSION := $(shell git --git-dir=ginac/.git describe --tags | sed -rne 's/^release_([0-9]+)[-]([0-9]+)[-]([0-9]+)(.*)$$/\1.\2.\3\4/p')
