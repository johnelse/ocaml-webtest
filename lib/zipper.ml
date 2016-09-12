type crumb = {
  left: Suite.t list;
  label: string;
  right: Suite.t list;
}

type t = {
  crumbs: crumb list;
  location: Suite.t;
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
    location =
      Suite.TestList (label, List.rev_append (location :: left) right);
  }

let move_down {crumbs; location} =
  match location with
  (* A TestCase has no children. *)
  | Suite.TestCase _ -> None
  (* A TestList may not have any children to move down to. *)
  | Suite.TestList (label, []) -> None
  (* Move down to the first child of the TestList. *)
  | Suite.TestList (label, first_child :: other_children) -> Some {
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
  (* Move to the next sibling to the right. *)
  | (Some zipper') as result -> result
  (* No more siblings, so try to move up. *)
  | None -> begin
    match move_up zipper with
    (* If moving up succeeds, try moving right again. *)
    | Some zipper' -> next_sibling zipper'
    (* We can't move up, so we must be at the top of the tree. *)
    | None -> None
  end

let next_location zipper =
  match move_down zipper with
  | Some zipper' as result -> result
  | None -> next_sibling zipper

let get_labels {crumbs; location} =
  let location_label = match location with
  | Suite.TestCase (label, _) -> label
  | Suite.TestList (label, _) -> label
  in
  location_label :: (List.map (fun crumb -> crumb.label) crumbs) |> List.rev
