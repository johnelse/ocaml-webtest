(** Types and functions for creating and structuring unit test suites. *)

exception TestFailure of string
(** The exception thrown by failing tests. *)

type result =
  | Error of exn           (** An unexpected error occurred in the test. *)
  | Fail of string         (** An assertion failed in the test. *)
  | Pass                   (** The test passed. *)
(** The result of running a single testcase. *)

module Sync : sig
  type test_fun = unit -> unit
  (** A synchronous test function. *)

  val bracket : (unit -> 'a) -> ('a -> unit) -> ('a -> unit) -> test_fun
  (** [bracket setup test teardown] generates a
      {{:#TYPEtest_fun}test_fun} which will use [setup] to create
      state needed for the test, then pass that state to [test], and finally
      will pass that state to [teardown]. *)
end

module Async : sig
  type callback = unit -> unit
  (** The type of an asynchronous callback which will run as part of an
      asynchronous test. *)

  val noop : callback
  (** The noop callback - this is just an alias for [fun () -> ()]. *)

  type wrapper = callback -> unit
  (** A wrapper function to be passed to an asynchronous test. *)

  type test_fun = wrapper -> unit
  (** An asynchronous test function. When run it will be passed a wrapper
      function - this should be used to wrap any asynchronous code which the
      test case is expected to run. *)

  val bracket :
    (unit -> 'a) -> ('a -> wrapper -> unit) -> ('a -> unit) -> test_fun
  (** [bracket setup test teardown] generates a
      {{:#TYPEtest_fun}test_fun} which will use [setup] to create
      state needed for the test, then pass that state to [test], and finally
      will pass that state to [teardown]. *)

  val run_one : test_fun -> (string -> unit )-> (result -> unit) -> unit
  (** Run an asynchronous test and pass its result to a callback. *)

  val of_sync : Sync.test_fun -> test_fun
  (** Convert a synchronous test into an asynchronous test. *)
end

type t =
  | TestCase of string * Async.test_fun (** A labelled single test. *)
  | TestList of string * t list         (** A labelled list of tests. *)
  (** A labelled wrapper around a test or list of suites. *)

val (>::) : string -> Sync.test_fun -> t
(** Convenience function to create a suite from a label and a
    {{:Suite.Sync.html#TYPEtest_fun}Sync.test_fun}. *)
val (>:~) : string -> Async.test_fun -> t
(** Convenience function to create a suite from a label and an
    {{:Suite.Async.html#TYPEtest_fun}Async.test_fun}. *)
val (>:::) : string -> t list -> t
(** Convenience function to create a suite from a label and a list of suites. *)

val assert_true : ?label:string -> bool -> unit
(** [assert_bool label value] returns unit if [value] is true, and otherwise
    raises {{:#EXCEPTIONTestFailure}TestFailure}. *)

val assert_equal :
  ?equal:('a -> 'a -> bool) -> ?label:string ->
  ?printer:('a -> string) -> 'a -> 'a -> unit
(** [assert_equal a b] returns unit if [a] is equal to [b], and otherwise
    raises {{:#EXCEPTIONTestFailure}TestFailure}. *)

val assert_raises : ?label:string -> exn -> (unit -> unit) -> unit
(** [assert_raises e task] returns unit if [task ()] raises [e], and otherwise
    raises {{:#EXCEPTIONTestFailure}TestFailure}. *)

val assert_raises_string : ?label:string -> string -> (unit -> unit) -> unit
(** [assert_raises_string str task] returns unit if [task ()] raises an
    exception [e] for which [Printexc.to_string e = str], and otherwise
    raises {{:#EXCEPTIONTestFailure}TestFailure}. *)
