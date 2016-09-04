ocaml-webtest
=============

[![Build status](https://travis-ci.org/johnelse/ocaml-webtest.png?branch=master)](https://travis-ci.org/johnelse/ocaml-webtest)
[![API reference](https://img.shields.io/badge/docs-API_reference-blue.svg)](https://johnelse.github.io/ocaml-webtest)

A unit test framework, fully compatible with
[js_of_ocaml](https://github.com/ocsigen/js_of_ocaml), and written with
in-browser testing of Javascript code in mind.

Heavily influenced by [oUnit](http://ounit.forge.ocamlcore.org/).

You may find this helpful if you want to

* test OCaml bindings to a javascript library
* write tests for a Javascript library compiled from OCaml

You could even use this library to test normal OCaml code, but in that case
you're probably better off just using oUnit for the extra features it provides.

## Contents

`ocaml-webtest` consists of two libraries:

* `webtest`

This has no dependencies, and contains code for creating tests and suites.

* `webtest.js`

This depends on `js_of_ocaml`, and contains code used for running tests in a
browser.
