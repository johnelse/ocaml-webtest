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

exception TestFailure of string
(** The exception thrown by failing tests. *)

type result =
  | Error of exn           (** An unexpected error occurred in the test. *)
  | Failure of string      (** An assertion failed in the test. *)
  | Success                (** The test passed. *)
(** The result of running a single testcase. *)

val bracket : (unit -> 'a) -> ('a -> unit) -> ('a -> unit) -> test_fun
(** [bracket setup test teardown] generates a {{:#TYPEtest_fun}test_fun} which will use
    [setup] to create state needed for the test, then pass that state to [test],
    and finally will pass that state to [teardown]. *)

val assert_true : string -> bool -> unit
(** [assert_bool label value] returns unit if [value] is true, and otherwise
    raises {{:#EXCEPTIONTestFailure}TestFailure}. *)

val assert_equal : ?printer:('a -> string) -> 'a -> 'a -> unit
(** [assert_equal a b] returns unit if [a] is equal to [b], and otherwise
    raises {{:#EXCEPTIONTestFailure}TestFailure}. *)
