exception TestFailure of string

type result =
  | Error of exn
  | Failure of string
  | Success

let string_of_result = function
  | Error e -> Printf.sprintf "Error: %s" (Printexc.to_string e)
  | Failure msg -> Printf.sprintf "Failure: %s" msg
  | Success -> "Success"

let finally f cleanup =
  let result =
    try f ()
    with e ->
      cleanup ();
      raise e
  in
  cleanup ();
  result

module Sync = struct
  type test_fun = unit -> unit

  let bracket setup test teardown () =
    let state = setup () in
    finally
      (fun () -> test state)
      (fun () -> teardown state)
end

module Async = struct
  type callback = unit -> unit

  type test_fun = callback -> unit

  let bracket setup test teardown =
    (fun callback ->
      let state = setup () in
      finally
        (fun () -> test state callback)
        (fun () -> teardown state; callback ()))

  let run_one test log handle_result =
    let log_and_handle_result result =
      log "End";
      log (string_of_result result);
      handle_result result
    in
    try
      log "Start";
      test (fun () -> log_and_handle_result Success)
    with
      | TestFailure msg -> log_and_handle_result (Failure msg)
      | e -> log_and_handle_result (Error e)

  let of_sync test callback =
    test ();
    callback ()
end

type t =
  | TestCase of string * Async.test_fun
  | TestList of string * t list

let (>::) label test_fun = TestCase (label, Async.of_sync test_fun)
let (>:~) label test_fun = TestCase (label, test_fun)
let (>:::) label tests = TestList (label, tests)

let assert_true label value =
  if not value then begin
    let msg = Printf.sprintf "test value was false: %s" label in
    raise (TestFailure msg)
  end

let assert_equal ?printer a b =
  if a <> b
  then begin
    let msg = match printer with
    | Some printer -> Printf.sprintf "not equal: %s %s" (printer a) (printer b)
    | None -> Printf.sprintf "not equal"
    in
    raise (TestFailure msg)
  end
