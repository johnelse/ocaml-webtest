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

let run suite =
  let log_buf = Buffer.create 0 in
  let log_with_prefix prefix msg =
    Buffer.add_string log_buf prefix;
    Buffer.add_string log_buf msg;
    Buffer.add_char log_buf '\n'
  in
  let zipper = Zipper.of_suite suite in
  let rec run' ({Zipper.location} as zipper) results =
    let continue zipper results =
      match Zipper.next_location zipper with
      | Some zipper' -> run' zipper' results
      | None -> results
    in
    match location with
    | Suite.TestCase (label, f) ->
      let prefix = Zipper.get_labels zipper |> String.concat ":" in
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
      let results = result :: results in
      continue zipper results
    | Suite.TestList (label, children) ->
      continue zipper results
  in
  let results = List.rev (run' zipper []) in
  {
    log = Buffer.contents log_buf;
    results;
  }
