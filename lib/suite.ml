type test_fun = unit -> unit

type t =
  | TestCase of string * test_fun
  | TestList of string * t list

let (>::) label f = TestCase (label, f)
let (>:::) label tests = TestList (label, tests)

let finally f cleanup =
  let result =
    try f ()
    with e ->
      cleanup ();
      raise e
  in
  cleanup ();
  result

let bracket setup test teardown () =
  let state = setup () in
  finally
    (fun () -> test state)
    (fun () -> teardown state)
