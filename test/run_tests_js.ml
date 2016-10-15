(* Test suite which runs in the browser as Javascript. *)

let suite =
  let open Webtest.Suite in
  "js_suite" >::: [
    Test_assert.suite;
    Test_async.suite;
    Test_js.suite;
    Test_sync.suite;
  ]

let () = Webtest_js.Runner.setup suite
