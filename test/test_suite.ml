module T = Webtest

let (>::) = T.(>::)
let (>:::) = T.(>:::)

let test_assert_equal_ok () =
  T.assert_equal 5 5

let test_assert_equal_fail () =
  try
    T.assert_equal 5 6;
    failwith "assert_equal should have failed"
  with T.TestFailure "not equal" -> ()

let suite =
  "base_suite" >::: [
    "test_assert_equal_ok" >:: test_assert_equal_ok;
    "test_assert_equal_fail" >:: test_assert_equal_fail;
  ]

let run_suite log =
  let open T in
  let results = run log suite in
  let total, errored, failed, succeeded =
    List.fold_left
      (fun (total, errors, failures, successes) result ->
        match result with
        | Error _ -> total + 1, errors + 1, failures, successes
        | Failure _ -> total + 1, errors, failures + 1, successes
        | Success -> total + 1, errors, failures, successes + 1)
      (0, 0, 0, 0) results
  in
  log (Printf.sprintf "%d tests run" total);
  log (Printf.sprintf "%d errors" errored);
  log (Printf.sprintf "%d failures" failed);
  log (Printf.sprintf "%d succeeded" succeeded)

