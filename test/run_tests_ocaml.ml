open Webtest

let () =
  Utils.run Test_base_suite.suite
    (fun output ->
      let {Utils.log; passed} = Utils.summarise output in
      print_endline log;
      if not passed
      then exit 1)
