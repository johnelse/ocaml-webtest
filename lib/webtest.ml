type test_fun = unit -> unit

type suite =
  | TestCase of string * test_fun
  | TestList of string * suite list

module Zipper = struct
  type crumb = {
    left: suite list;
    label: string;
    right: suite list;
  }

  type t = {
    crumbs: crumb list;
    location: suite;
  }

  let of_suite suite = {
    crumbs = [];
    location = suite;
  }

  let to_suite {location} = location

  let move_up {crumbs; location} =
    match crumbs with
    (* Already at the top of the tree, so nowhere to go. *)
    | [] -> None
    (* Move to the head of the list of crumbs. *)
    | {left; label; right} :: other_crumbs -> Some {
      crumbs = other_crumbs;
      location = TestList
        (label, List.rev_append (location :: left) right);
    }

  let move_down {crumbs; location} =
    match location with
    (* A TestCase has no children. *)
    | TestCase _ -> None
    (* A TestList may not have any children to move down to. *)
    | TestList (label, []) -> None
    (* Move down to the first child of the TestList. *)
    | TestList (label, first_child :: other_children) -> Some {
      crumbs = {
        left = [];
        label;
        right = other_children;
      } :: crumbs;
      location = first_child;
    }

  let move_right {crumbs; location} =
    match crumbs with
    (* At the top of the tree, so no siblings. *)
    | [] -> None
    (* Already at the rightmost sibling. *)
    | {right = []} :: _ -> None
    (* Move to the next sibling to the right. *)
    | {left; label; right = first_right :: other_right} :: other_crumbs -> Some {
      crumbs = {
        left = location :: left;
        label;
        right = other_right;
      } :: other_crumbs;
      location = first_right;
    }

  let rec next_sibling zipper =
    match move_right zipper with
    | (Some zipper') as result -> result
    | None -> begin
      match move_up zipper with
      | Some zipper' -> next_sibling zipper'
      | None -> None
    end

  let rec next_location zipper =
    match move_down zipper with
    | Some zipper' as result -> result
    | None -> next_sibling zipper

  let get_labels {crumbs; location} =
    let location_label = match location with
    | TestCase (label, _) -> label
    | TestList (label, _) -> label
    in
    location_label :: (List.map (fun crumb -> crumb.label) crumbs) |> List.rev
end

exception TestFailure of string

type result =
  | Error of exn
  | Failure of string
  | Success

type output = {
  log: string;
  results: result list;
}

let string_of_result = function
  | Error e -> Printf.sprintf "Error: %s" (Printexc.to_string e)
  | Failure msg -> Printf.sprintf "Failure: %s" msg
  | Success -> "Success"

let (>::) label f = TestCase (label, f)
let (>:::) label tests = TestList (label, tests)

let assert_true label value =
  if not value then begin
    let msg = Printf.sprintf "test value was false: %s" label in
    raise (TestFailure msg)
  end

let assert_equal ?printer a b =
  if a <> b
  then begin
    let msg = match printer with
    | Some printer -> Printf.sprintf "not equal: %s %s" (printer a) (printer b)
    | None -> Printf.sprintf "not equal"
    in
    raise (TestFailure msg)
  end

let finally f cleanup =
  let result =
    try f ()
    with e ->
      cleanup ();
      raise e
  in
  cleanup ();
  result

let bracket setup test teardown () =
  let state = setup () in
  finally
    (fun () -> test state)
    (fun () -> teardown state)

let run suite =
  let log_buf = Buffer.create 0 in
  let log_with_prefix prefix msg =
    Buffer.add_string log_buf prefix;
    Buffer.add_string log_buf msg;
    Buffer.add_char log_buf '\n'
  in
  let rec run' prefix results = function
    | TestCase (label, f) ->
      let prefix = Printf.sprintf "%s%s:" prefix label in
      let log = log_with_prefix prefix in
      log "Start";
      let result =
        try
          f ();
          Success
        with
          | TestFailure msg -> Failure msg
          | e -> Error e
      in
      log "End";
      log (string_of_result result);
      result :: results
    | TestList (label, children) ->
      let prefix = Printf.sprintf "%s%s:" prefix label in
      List.fold_left (run' prefix) results children
  in
  let results = List.rev (run' "" [] suite) in
  {
    log = Buffer.contents log_buf;
    results;
  }
