(* Javascript-specific tests. *)

open Webtest.Suite

let test_async_wrapper wrapper =
  let (_:Dom_html.timeout_id_safe) =
    Dom_html.setTimeout (fun () -> wrapper Async.noop) 0.5 in ()

let suite =
  "js" >::: [
    "test_async_wrapper" >:~ test_async_wrapper;
  ]
