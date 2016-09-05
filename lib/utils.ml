type output = {
  log: string;
  results: Suite.result list;
}

type summary = {
  log: string;
  passed: bool;
}

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
      | None ->
        callback {
          log = Buffer.contents log_buf;
          results = List.rev results
        }
    in
    match location with
    | Suite.TestCase (label, test_fun) ->
      let prefix = Zipper.get_labels zipper |> String.concat ":" in
      let log = log_with_prefix prefix in
      Suite.Async.run_one test_fun log
        (fun result -> continue zipper (result :: results))
    | Suite.TestList (label, children) ->
      continue zipper results
  in
  run' zipper []

let summarise {log; results} =
  let total, errors, failures, passes =
    List.fold_left
      (fun (total, errors, failures, passes) result ->
        let open Suite in
        match result with
        | Error _ -> total + 1, errors + 1, failures, passes
        | Fail _ -> total + 1, errors, failures + 1, passes
        | Pass -> total + 1, errors, failures, passes + 1)
      (0, 0, 0, 0) results
  in
  let final_log =
    String.concat "\n" [
      log;
      Printf.sprintf "%d tests run" total;
      Printf.sprintf "%d errors" errors;
      Printf.sprintf "%d failures" failures;
      Printf.sprintf "%d passes" passes;
    ]
  in
  let passed = total = passes in
  {
    log = final_log;
    passed;
  }
