open Webtest

let test_assert_equal_ok () =
  assert_equal 5 5

let test_assert_equal_fail () =
  try
    assert_equal 5 6;
    failwith "assert_equal should have failed"
  with TestFailure "not equal" -> ()

let suite =
  "base_suite" >::: [
    "test_assert_equal_ok" >:: test_assert_equal_ok;
    "test_assert_equal_fail" >:: test_assert_equal_fail;
  ]
