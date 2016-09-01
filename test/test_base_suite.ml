open Webtest.Suite

let suite =
  "base_suite" >::: [
    Test_sync.suite;
  ]
