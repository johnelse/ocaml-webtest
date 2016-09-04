open Webtest.Suite

let suite =
  "base_suite" >::: [
    Test_assert.suite;
    Test_async.suite;
    Test_sync.suite;
  ]
