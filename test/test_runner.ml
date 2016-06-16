module Html = Dom_html

let start _ =
  let open Js.Unsafe in
  let webtest = Js.Unsafe.obj [||] in
  webtest##finished <- Js._false;
  webtest##passed <- Js._false;
  webtest##run <- Js.wrap_callback
    (fun () ->
      let logs : string list ref = ref [] in
      let log line = logs := line :: !logs in
      Test_suite.run_suite log;
      webtest##logs <-
        Js.string (List.rev !logs |> String.concat "\n");
      webtest##passed <- Js._true;
      webtest##finished <- Js._true);

  global##webtest <- webtest;

  Js._false

let () =
  Html.window##onload <- Html.handler start
