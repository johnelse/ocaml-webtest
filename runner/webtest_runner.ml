module Html = Dom_html

let run suite _ =
  let open Js.Unsafe in
  let webtest = Js.Unsafe.obj [||] in
  webtest##.finished := Js._false;
  webtest##.passed := Js._false;
  webtest##.run := Js.wrap_callback
    (fun () ->
      let open Webtest in
      Utils.run suite (fun results ->
        let {Utils.log; passed} = Utils.summarise results in
        webtest##.log := Js.string log;
        webtest##.passed := if passed then Js._true else Js._false;
        webtest##.finished := Js._true));

  global##.webtest := webtest;

  Js._false

let setup suite =
  Html.window##.onload := Html.handler (run suite)
