type test_fun  = unit -> unit

exception TestFailure of string

type result =
  | Error of exn
  | Failure of string
  | Success

type test =
  | TestCase of string * test_fun
  | TestList of string * test list

val (>::) : string -> test_fun -> test
val (>:::) : string -> test list -> test

val assert_equal : ?printer:('a -> string) -> 'a -> 'a -> unit

val run : (string -> unit) -> test -> result list

val bracket : (unit -> 'a) -> ('a -> unit) -> ('a -> unit) -> test_fun
