let suite =
  let open Webtest.Suite in
  "js_suite" >::: [
    Test_assert.suite;
    Test_async.suite;
    Test_sync.suite;
  ]

let () = Webtest_runner.setup suite
