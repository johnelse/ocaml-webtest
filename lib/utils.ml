type output = {
  log: string list;
  outcomes: Suite.outcome list;
}

type raw_summary = {
    total: int;
    errors: int;
    failures: int;
    passes: int;
    passed: bool
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
  let rec run' ({Zipper.location} as zipper) outcomes =
    let continue zipper outcomes' =
      match Zipper.next_location zipper with
      | Some zipper' -> run' zipper' outcomes'
      | None ->
        callback {
          log = List.rev !log;
          outcomes = List.rev outcomes'
        }
    in
    match location with
    | Suite.TestCase (label, test_fun) ->
      let prefix = Zipper.get_labels zipper |> String.concat ":" in
      let log = log_with_prefix prefix in
      Suite.Async.run_one prefix test_fun log
                  (fun outcome -> continue zipper (outcome :: outcomes))
    | Suite.TestList (label, children) ->
       continue zipper outcomes
  in
  run' zipper []

let summarise_raw outcomes =
  let total, errors, failures, passes =
    List.fold_left
      (fun (total, errors, failures, passes) outcome ->
        let open Suite in
        match outcome.result with
        | Error _ -> total + 1, errors + 1, failures, passes
        | Fail _ -> total + 1, errors, failures + 1, passes
        | Pass -> total + 1, errors, failures, passes + 1)
      (0, 0, 0, 0) outcomes
  in
  {
    total; errors; failures; passes;
    passed = (total = passes)
  }

let summarise outcomes =
  let raw = summarise_raw outcomes in
  let report = String.concat "\n" [
                               Printf.sprintf "%d tests run" raw.total;
                               Printf.sprintf "%d errors" raw.errors;
                               Printf.sprintf "%d failures" raw.failures;
                               Printf.sprintf "%d passes" raw.passes;
                             ]
  in
  {
    report;
    passed = raw.passed;
  }
