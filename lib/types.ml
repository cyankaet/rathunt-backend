(** internal represntation of a team, can be translated to a JSON for
    return *)
module Team = struct
  type t = {
    id : int;
    name : string;
    solves : int;
  }

  let yojson_of_t t =
    `Assoc
      [
        ("name", `String t.name);
        ("id", `Int t.id);
        ("solves", `Int t.solves);
      ]
end

(** internal represntation of a puzzle, can be translated to a JSON for
    return *)
module Puzzle = struct
  type t = {
    id : int;
    name : string;
    answer : string;
  }

  let yojson_of_t t =
    `Assoc
      [
        ("id", `Int t.id);
        ("name", `String t.name);
        ("answer", `String t.answer);
      ]
end