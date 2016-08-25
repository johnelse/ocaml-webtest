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
  let total, errored, failed, succeeded =
    List.fold_left
      (fun (total, errors, failures, successes) result ->
        let open Suite in
        match result with
        | Error _ -> total + 1, errors + 1, failures, successes
        | Failure _ -> total + 1, errors, failures + 1, successes
        | Success -> total + 1, errors, failures, successes + 1)
      (0, 0, 0, 0) results
  in
  let final_log =
    String.concat "\n" [
      log;
      Printf.sprintf "%d tests run" total;
      Printf.sprintf "%d errors" errored;
      Printf.sprintf "%d failures" failed;
      Printf.sprintf "%d succeeded" succeeded;
    ]
  in
  let passed = total = succeeded in
  {
    log = final_log;
    passed;
  }
