type output = {
  log: string list;
  results: Suite.result list;
}

type summary = {
  report: string;
  passed: bool;
}

let run suite callback =
  let log = ref [] in
  let log_with_prefix prefix msg =
    let line = Printf.sprintf "%s:%s" prefix msg in
    log := (line :: !log)
  in
  let zipper = Zipper.of_suite suite in
  let rec run' ({Zipper.location} as zipper) results =
    let continue zipper results =
      match Zipper.next_location zipper with
      | Some zipper' -> run' zipper' results
      | None ->
        callback {
          log = List.rev !log;
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

let summarise results =
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
  let report =
    String.concat "\n" [
      Printf.sprintf "%d tests run" total;
      Printf.sprintf "%d errors" errors;
      Printf.sprintf "%d failures" failures;
      Printf.sprintf "%d passes" passes;
    ]
  in
  let passed = total = passes in
  {
    report;
    passed;
  }
