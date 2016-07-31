(** Types and functions for creating and structuring unit test suites. *)

type test_fun = unit -> unit
(** A test function. *)

type t =
  | TestCase of string * test_fun (** A labelled single test. *)
  | TestList of string * t list   (** A labelled list of tests. *)
  (** A labelled wrapper around a test or list of suites. *)

val (>::) : string -> test_fun -> t
(** Convenience function to create a suite from a label and a
    {{:#TYPEtest_fun}test_fun}. *)
val (>:::) : string -> t list -> t
(** Convenience function to create a suite from a label and a list of suites. *)

val bracket : (unit -> 'a) -> ('a -> unit) -> ('a -> unit) -> test_fun
(** [bracket setup test teardown] generates a {{:#TYPEtest_fun}test_fun} which will use
    [setup] to create state needed for the test, then pass that state to [test],
    and finally will pass that state to [teardown]. *)
