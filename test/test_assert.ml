(* Test the assert functions. *)

open Webtest.Suite

exception MyException of int

let test_assert_true_ok () =
  assert_true ~label:"should pass" true

let test_assert_true_fail () =
  try
    assert_true ~label:"test_bool" false;
    failwith "assert_true should have failed"
  with TestFailure "test value was false (test_bool)" -> ()

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

let test_assert_raises_ok () =
  assert_raises (MyException 0) (fun () -> raise (MyException 0))

let test_assert_raises_no_exn () =
  try assert_raises (MyException 0) (fun () -> ())
  with TestFailure "expected exception not raised" -> ()

let test_assert_raises_wrong_exn () =
  try assert_raises (MyException 0) (fun () -> raise (MyException 1))
  with
   | TestFailure "unexpected exception raised: Test_assert.MyException(1)" -> ()

let test_assert_raises_string_ok () =
  assert_raises_string
    "Test_assert.MyException(0)"
    (fun () -> raise (MyException 0))

let test_assert_raises_string_no_exn () =
  try assert_raises_string "Test_assert.MyException(0)" (fun () -> ())
  with TestFailure "expected exception not raised" -> ()

let test_assert_raises_string_wrong_exn () =
  try
    assert_raises_string
      "Test_assert.MyException(0)"
      (fun () -> raise (MyException 1))
  with
   | TestFailure "unexpected exception raised: Test_assert.MyException(1)" -> ()

let suite =
  "assert" >::: [
    "test_assert_true_ok" >:: test_assert_true_ok;
    "test_assert_true_fail" >:: test_assert_true_fail;
    "test_assert_equal_ok" >:: test_assert_equal_ok;
    "test_assert_equal_fail" >:: test_assert_equal_fail;
    "test_assert_equal_printer" >:: test_assert_equal_printer;
    "test_assert_raises_ok" >:: test_assert_raises_ok;
    "test_assert_raises_no_exn" >:: test_assert_raises_no_exn;
    "test_assert_raises_wrong_exn" >:: test_assert_raises_wrong_exn;
    "test_assert_raises_string_ok" >:: test_assert_raises_string_ok;
    "test_assert_raises_string_no_exn" >:: test_assert_raises_string_no_exn;
    "test_assert_raises_string_wrong_exn" >::
      test_assert_raises_string_wrong_exn;
  ]
