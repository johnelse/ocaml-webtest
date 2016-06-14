(** Types and functions for creating and working with unit tests. *)

type test_fun  = unit -> unit
(** A test function. *)

exception TestFailure of string
(** The exception thrown by failing tests. *)

type result =
  | Error of exn           (** An unexpected error occurred in the test. *)
  | Failure of string      (** An assertion failed in the test. *)
  | Success                (** The test passed. *)
(** The result of running a test. *)

type test =
  | TestCase of string * test_fun    (** A labelled single test. *)
  | TestList of string * test list   (** A labelled list of tests. *)
(** A labelled wrapper around a test or list of tests. *)

val (>::) : string -> test_fun -> test
(** Convenience function to create a test from a label and a
    {{:#TYPEtest_fun}test_fun}. *)
val (>:::) : string -> test list -> test
(** Convenience function to create a test from a label and a list of tests. *)

val assert_equal : ?printer:('a -> string) -> 'a -> 'a -> unit

val run : (string -> unit) -> test -> result list
(** [run log test] runs [test], and passes any logging to the [log] function. *)

val bracket : (unit -> 'a) -> ('a -> unit) -> ('a -> unit) -> test_fun
(** [bracket setup test teardown] generates a {{:#TYPEtest_fun}test_fun} which will use
    [setup] to create state needed for the test, then pass that state to [test],
    and finally will pass that state to [teardown]. *)
