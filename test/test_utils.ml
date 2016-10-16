(* Common test helper functions. *)

let run_one_sync async_test =
  let result_ref = ref None in
  Webtest.Suite.Async.run_one
    async_test
    (fun _ -> ())
    (fun result -> result_ref := Some result);
  !result_ref
