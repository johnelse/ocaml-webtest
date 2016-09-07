open Webtest

let suite =
  let open Webtest.Suite in
  "ocaml_suite" >::: [
    Test_assert.suite;
    Test_async.suite;
    Test_sync.suite;
  ]

let () =
  Utils.run suite
    (fun output ->
      let {Utils.log; passed} = Utils.summarise output in
      print_endline log;
      if not passed
      then exit 1)
