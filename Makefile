all: build test/test_runner.js

test/test_runner.js: build
	js_of_ocaml test_runner.byte -o $@

NAME=webtest
SETUP=ocaml setup.ml

CONFIGUREFLAGS=--enable-tests

build: setup.data
	$(SETUP) -build $(BUILDFLAGS)

doc: setup.data build
	$(SETUP) -doc $(DOCFLAGS)

test: setup.data build
	$(SETUP) -test $(TESTFLAGS)

install: setup.data
	$(SETUP) -install $(INSTALLFLAGS)

uninstall: setup.data
	ocamlfind remove $(NAME)

reinstall: setup.data
	ocamlfind remove $(NAME) || true
	$(SETUP) -reinstall $(REINSTALLFLAGS)

clean:
	$(SETUP) -clean $(CLEANFLAGS)
	rm -f test/test_runner.js

distclean:
	$(SETUP) -distclean $(DISTCLEANFLAGS)

setup.data:
	$(SETUP) -configure $(CONFIGUREFLAGS)

configure:
	$(SETUP) -configure $(CONFIGUREFLAGS)

.PHONY: build doc test all install uninstall reinstall clean distclean configure
