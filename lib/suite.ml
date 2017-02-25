exception TestFailure of string

type result =
  | Error of exn
  | Fail of string
  | Pass
type outcome = {
  label: string;
  result: result;
  time_s: float;
}

let string_of_result = function
  | Error e -> Printf.sprintf "Error: %s" (Printexc.to_string e)
  | Fail msg -> Printf.sprintf "Fail: %s" msg
  | Pass -> "Pass"

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
  let noop () = ()

  type wrapper = callback -> unit
  type test_fun = wrapper -> unit

  let bracket setup test teardown =
    (fun wrapper ->
      let state = setup () in
      let wrapper' f =
        wrapper (fun () -> finally f (fun () -> teardown state)) in
      try
        test state wrapper'
      with e ->
        teardown state;
        raise e)

  let run_one label test log handle_outcome =
    (* Make sure we only handle one result per test. This prevents a successful
       callback from triggering a continuation of the tests if the synchronous
       code has already failed or errored. *)
    let handled = ref false in
    let start_time = ref 0.0 in
    let handle_result_once result =
      if not !handled
      then begin
        handled := true;
        log "End";
        log (string_of_result result);
        handle_outcome {label; result; time_s = Sys.time () -. !start_time}
      end
    in
    let catch_all f =
      try f ()
      with
        | TestFailure msg -> handle_result_once (Fail msg)
        | e -> handle_result_once (Error e)
    in
    (* This catch_all will catch failures and errors coming from the
       synchronous part of the test case, i.e. before the callback has been
       triggered. *)
    catch_all (fun () ->
      log "Start";
      start_time := Sys.time ();
      test
        (fun callback ->
          (* This catch_all will catch failures and errors coming from the
             asynchronous callback. *)
          catch_all (fun () ->
            callback ();
            handle_result_once Pass)))

  let of_sync test wrapper =
    test ();
    wrapper noop
end

type t =
  | TestCase of string * Async.test_fun
  | TestList of string * t list

let (>::) label test_fun = TestCase (label, Async.of_sync test_fun)
let (>:~) label test_fun = TestCase (label, test_fun)
let (>:::) label tests = TestList (label, tests)

let string_of_opt = function
  | Some value -> Printf.sprintf " (%s)" value
  | None -> ""

let assert_true ?label value =
  if not value then begin
    let msg = Printf.sprintf "test value was false%s" (string_of_opt label) in
    raise (TestFailure msg)
  end

let assert_equal ?(equal = (=)) ?label ?printer a b =
  if not (equal a b)
  then begin
    let values = match printer with
    | Some printer -> Printf.sprintf ": %s %s" (printer a) (printer b)
    | None -> ""
    in
    let msg = Printf.sprintf "not equal%s%s" (string_of_opt label) values in
    raise (TestFailure msg)
  end

let assert_raises ?label expected_exn task =
  match
    try task (); None
    with raised_exn -> Some raised_exn
  with
  | None ->
    let msg =
      Printf.sprintf
        "expected exception not raised%s" (string_of_opt label)
    in
    raise (TestFailure msg)
  | Some raised_exn when raised_exn = expected_exn -> ()
  | Some raised_exn ->
    let msg =
      Printf.sprintf
        "unexpected exception raised%s: %s"
        (string_of_opt label)
        (Printexc.to_string raised_exn)
    in
    raise (TestFailure msg)

let assert_raises_string ?label expected_exn_string task =
  match
    try task (); None
    with raised_exn -> Some raised_exn
  with
  | None ->
    let msg =
      Printf.sprintf
        "expected exception not raised%s" (string_of_opt label)
    in
    raise (TestFailure msg)
  | Some raised_exn
    when (Printexc.to_string raised_exn) = expected_exn_string -> ()
  | Some raised_exn ->
    let msg =
      Printf.sprintf
        "unexpected exception raised%s: %s"
        (string_of_opt label)
        (Printexc.to_string raised_exn)
    in
    raise (TestFailure msg)
