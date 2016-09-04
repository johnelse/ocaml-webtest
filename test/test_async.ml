open Webtest.Suite

let run_one_sync async_test =
  let result_ref = ref None in
  Async.run_one
    async_test
    (fun _ -> ())
    (fun result -> result_ref := Some result);
  !result_ref

let test_callback callback = callback ()

let test_run_one_ok () =
  assert_equal
    (run_one_sync (fun callback -> callback ()))
    (Some Success)

let test_run_one_fail () =
  assert_equal
    (run_one_sync (fun _ -> assert_equal 5 6))
    (Some (Failure "not equal"))

let test_run_one_error () =
  assert_equal
    (run_one_sync (fun _ -> failwith "fail"))
    (Some (Error (Failure "fail")))

let suite =
  "async" >::: [
    "test_callback" >:~ test_callback;
    "test_run_one_ok" >:: test_run_one_ok;
    "test_run_one_fail" >:: test_run_one_fail;
    "test_run_one_error" >:: test_run_one_error;
  ]
