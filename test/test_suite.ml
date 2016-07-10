open Webtest

let test_assert_true_ok () =
  assert_true "should pass" true

let test_assert_true_fail () =
  try
    assert_true "test_bool" false;
    failwith "assert_true should have failed"
  with TestFailure "test value was false: test_bool" -> ()

let test_assert_equal_ok () =
  assert_equal 5 5

let test_assert_equal_fail () =
  try
    assert_equal 5 6;
    failwith "assert_equal should have failed"
  with TestFailure "not equal" -> ()

let test_assert_equal_printer () =
  try
    assert_equal ~printer:string_of_int 5 6;
    failwith "assert_equal should have failed"
  with TestFailure "not equal: 5 6" -> ()

let test_bracket () =
  let state = ref `uninitialised in
  let setup () = state := `test_start; state in
  let teardown state =
    assert_equal !state `test_end;
    state := `torn_down
  in
  bracket
    setup
    (fun state ->
      assert_equal !state `test_start;
      state := `test_end)
    teardown ();
  assert_equal !state `torn_down

let suite =
  "base_suite" >::: [
    "test_assert_true_ok" >:: test_assert_true_ok;
    "test_assert_true_fail" >:: test_assert_true_fail;
    "test_assert_equal_ok" >:: test_assert_equal_ok;
    "test_assert_equal_fail" >:: test_assert_equal_fail;
    "test_assert_equal_printer" >:: test_assert_equal_printer;
    "test_bracket" >:: test_bracket;
  ]
