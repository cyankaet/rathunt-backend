(** internal represntation of a team, can be translated to a JSON for
    return *)
module Team = struct
  type t = {
    name : string;
    password : string;
  }

  let yojson_of_t t = `Assoc [ ("name", `String t.name) ]

  let team_of_vals (name, password) : t = { name; password }
end

(** internal represntation of a puzzle, can be translated to a JSON for
    return *)
module Puzzle = struct
  type t = {
    name : string;
    answer : string;
  }

  let yojson_of_t t =
    `Assoc [ ("name", `String t.name); ("answer", `String t.answer) ]
end