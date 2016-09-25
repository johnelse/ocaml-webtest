(* Test handling of asynchronous test cases. *)

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
    (Some Pass)

let test_run_one_fail () =
  assert_equal
    (run_one_sync (fun _ -> assert_equal 5 6))
    (Some (Fail "not equal"))

let test_run_one_error () =
  assert_equal
    (run_one_sync (fun _ -> failwith "fail"))
    (Some (Error (Failure "fail")))

let test_of_sync_ok () =
  let async_test = Async.of_sync (fun () -> ()) in
  assert_equal
    (run_one_sync async_test)
    (Some Pass)

let test_of_sync_fail () =
  let async_test = Async.of_sync (fun () -> assert_equal 5 6) in
  assert_equal
    (run_one_sync async_test)
    (Some (Fail "not equal"))

let test_of_sync_error () =
  let async_test = Async.of_sync (fun () -> failwith "fail") in
  assert_equal
    (run_one_sync async_test)
    (Some (Error (Failure "fail")))

let suite =
  "async" >::: [
    "test_callback" >:~ test_callback;
    "test_run_one_ok" >:: test_run_one_ok;
    "test_run_one_fail" >:: test_run_one_fail;
    "test_run_one_error" >:: test_run_one_error;
    "test_of_sync_ok" >:: test_of_sync_ok;
    "test_of_sync_fail" >:: test_of_sync_fail;
    "test_of_sync_error" >:: test_of_sync_error;
  ]
