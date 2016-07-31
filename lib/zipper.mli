(** A zipper implementation based on {{:Suite.html#TYPEt}Suite.t}, which
    represents the current location in the tree as well as the path used to
    reach the current location from the root. *)

type crumb = {
  left: Suite.t list;
  (** The list of siblings to the left of the current location. *)
  label: string;
  (** The label of the parent of the current location. *)
  right: Suite.t list;
  (** The list of siblings to the right of the current location. *)
}
(** A type representing the path through a {{:Suite.html#TYPEt}Suite.t} from the
    root to the current location. *)

type t = {
  crumbs: crumb list;
  (** The list of crumbs which leads to the current location in the tree. *)
  location: Suite.t;
  (** The current location in the tree. *)
}
(** A zipper implementation based on {{:Suite.html#TYPEt}Suite.t}. *)

val of_suite : Suite.t -> t
(** Convert a {{:Suite.html#TYPEt}Suite.t} into a {{:#TYPEt}Zipper.t}. *)
val to_suite : t -> Suite.t
(** Convert a {{:#TYPEt}Zipper.t} into a {{:Suite.html#TYPEt}Suite.t}.
    Note that this does not include the crumbs, only the subtree at the current
    location. *)

val move_up    : t -> t option
(** Attempt to move up to the parent node. *)
val move_down  : t -> t option
(** Attempt to move down to the first child node. *)
val move_right : t -> t option
(** Attempt to move right to the next sibling. *)

val next_location : t -> t option
(** Attempt to move to the next location while traversing the tree. Return None
    if we're already at the last location to be traversed. *)

val get_labels : t -> string list
(** Get the list of labels from all crumbs plus that of the current
    location, starting at the root of the tree. *)
