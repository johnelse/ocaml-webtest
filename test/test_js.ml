(* Javascript-specific tests. *)

open Webtest.Suite

let test_async_callback callback =
  let (_:Dom_html.timeout_id_safe) = Dom_html.setTimeout callback 0.5 in ()

let suite =
  "js" >::: [
    "test_async_callback" >:~ test_async_callback;
  ]
