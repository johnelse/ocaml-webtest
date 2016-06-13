module Html = Dom_html

let with_button_disabled button f =
  (Js.Unsafe.coerce button)##disabled <- Js._true;
  button##innerHTML <- Js.string "Running...";
  let result = f () in
  button##innerHTML <- Js.string "Run";
  (Js.Unsafe.coerce button)##disabled <- Js._false;
  result

let start _ =
  let button = Html.getElementById "run" in
  let info = Html.getElementById "info" in
  let log data = Dom.appendChild info
    (Html.document##createTextNode (Js.string (Printf.sprintf "%s\n" data)))
  in
  button##onclick <- Html.handler
    (fun _ ->
      List.iter
        (fun node -> Dom.removeChild info node)
        (info##childNodes |> Dom.list_of_nodeList);
      with_button_disabled button (fun () -> Test_suite.run_suite log);
      Js._false);
  Js._false

let () =
  Html.window##onload <- Html.handler start
