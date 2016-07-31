type output = {
  log: string;
  results: Suite.result list;
}

let string_of_result = function
  | Suite.Error e -> Printf.sprintf "Error: %s" (Printexc.to_string e)
  | Suite.Failure msg -> Printf.sprintf "Failure: %s" msg
  | Suite.Success -> "Success"

let run suite callback =
  let log_buf = Buffer.create 0 in
  let log_with_prefix prefix msg =
    Buffer.add_string log_buf prefix;
    Buffer.add_char log_buf ':';
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
          Suite.Success
        with
          | Suite.TestFailure msg -> Suite.Failure msg
          | e -> Suite.Error e
      in
      log "End";
      log (string_of_result result);
      let results = result :: results in
      continue zipper results
    | Suite.TestList (label, children) ->
      continue zipper results
  in
  let results = List.rev (run' zipper []) in
  callback {
    log = Buffer.contents log_buf;
    results;
  }
