module Html = Dom_html

let start test _ =
  let open Js.Unsafe in
  let webtest = Js.Unsafe.obj [||] in
  webtest##.finished := Js._false;
  webtest##.passed := Js._false;
  webtest##.run := Js.wrap_callback
    (fun () ->
      let {Webtest.Utils.log; results} = Webtest.Utils.run test in
      let total, errored, failed, succeeded =
        List.fold_left
          (fun (total, errors, failures, successes) result ->
            let open Webtest.Utils in
            match result with
            | Error _ -> total + 1, errors + 1, failures, successes
            | Failure _ -> total + 1, errors, failures + 1, successes
            | Success -> total + 1, errors, failures, successes + 1)
          (0, 0, 0, 0) results
      in
      let final_log =
        String.concat "\n" [
          log;
          Printf.sprintf "%d tests run" total;
          Printf.sprintf "%d errors" errored;
          Printf.sprintf "%d failures" failed;
          Printf.sprintf "%d succeeded" succeeded;
        ]
      in
      let passed = total = succeeded in
      webtest##.log := Js.string final_log;
      webtest##.passed := if passed then Js._true else Js._false;
      webtest##.finished := Js._true);

  global##.webtest := webtest;

  Js._false

let setup test =
  Html.window##.onload := Html.handler (start test)
