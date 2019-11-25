
gmp_VERSION := 5.1.3
cln_VERSION := $(shell git --git-dir=cln/.git describe --tags | sed -rne 's/^cln_([0-9]+)[-]([0-9]+)[-]([0-9]+)(.*)$$/\1.\2.\3\4/p')
ginac_VERSION := $(shell git --git-dir=ginac/.git describe --tags | sed -rne 's/^release_([0-9]+)[-]([0-9]+)[-]([0-9]+)(.*)$$/\1.\2.\3\4/p')
