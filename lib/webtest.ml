type test_fun = unit -> unit

exception TestFailure of string

type result =
  | Error of exn
  | Failure of string
  | Success

type output = {
  log: string;
  results: result list;
}

let string_of_result = function
  | Error e -> Printf.sprintf "Error: %s" (Printexc.to_string e)
  | Failure msg -> Printf.sprintf "Failure: %s" msg
  | Success -> "Success"

type test =
  | TestCase of string * test_fun
  | TestList of string * test list

let (>::) label f = TestCase (label, f)
let (>:::) label tests = TestList (label, tests)

let assert_equal ?printer a b =
  if a <> b
  then begin
    let msg = match printer with
    | Some printer -> Printf.sprintf "not equal: %s %s" (printer a) (printer b)
    | None -> Printf.sprintf "not equal"
    in
    raise (TestFailure msg)
  end

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

let run test =
  let log_buf = Buffer.create 0 in
  let log_with_prefix prefix msg =
    Buffer.add_string log_buf prefix;
    Buffer.add_string log_buf msg;
    Buffer.add_char log_buf '\n'
  in
  let rec run' prefix results = function
    | TestCase (label, f) ->
      let prefix = Printf.sprintf "%s%s:" prefix label in
      let log = log_with_prefix prefix in
      log "Start";
      let result =
        try
          f ();
          Success
        with
          | TestFailure msg -> Failure msg
          | e -> Error e
      in
      log "End";
      log (string_of_result result);
      result :: results
    | TestList (label, tests) ->
      let prefix = Printf.sprintf "%s%s:" prefix label in
      List.fold_left (run' prefix) results tests
  in
  let results = List.rev (run' "" [] test) in
  {
    log = Buffer.contents log_buf;
    results;
  }
