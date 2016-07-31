(** Types and functions for running tests in a browser. *)

val setup : Webtest.suite -> unit
(** [setup test] sets up a test runner and attaches it to the document's onLoad
    handler. *)
