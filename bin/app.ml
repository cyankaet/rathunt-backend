open Opium
open Opium.Request
open Lwt.Syntax
open Database
open Database.Types

(** [unwrap obj] unwraps the result monad for database operation,
    returning the result if there is no exn, otherwise raising the
    exception*)
let unwrap = function
  | Ok x -> x
  | Error (Db.Database_error exn) -> failwith exn

(** [read_form_data req] parses a FormData post request body and returns
    an association list of key-value pairs from the request. Raises
    [Failure "no form data"] if the request is empty.*)
let read_form_data req =
  let* req = to_multipart_form_data req in
  match req with
  | None -> failwith "no form data"
  | Some lst -> Lwt.return lst

(** convenience method to return a JSON with an optional status code
    containing only a string *)
let str_response ?(code = 200) str =
  Lwt.return
    (Response.of_json
       ?status:(Some (Status.of_code code))
       (`String str))

let hello_world _ = str_response "hello, world!"

(** [serialize_teams teams] creates a list of JSON objects representing
    a list of [teams] according to the team type *)
let serialize_teams (teams : Team.t list) =
  List.fold_left (fun acc x -> Team.yojson_of_t x :: acc) [] teams

let get_all_teams _ =
  let* teams = Db.get_all_teams () in
  let team_lst = unwrap teams |> serialize_teams in
  Lwt.return (Response.of_json (`List team_lst))

(** [serialize_puzzles puzzles] creates a list of JSON objects
    representing a list of [puzzles] according to the puzzle type *)
let serialize_puzzles (puzzles : Puzzle.t list) =
  List.fold_left (fun acc x -> Puzzle.yojson_of_t x :: acc) [] puzzles

let get_all_puzzles _ =
  let* puzzles = Db.get_all_puzzles () in
  let team_lst = unwrap puzzles |> serialize_puzzles in
  Lwt.return (Response.of_json (`List team_lst))

(** [serialize_puzzles puzzles] creates a list of JSON objects
    representing a list of [puzzles] according to the puzzle type *)
let serialize_solves solves =
  List.fold_left
    (fun acc x ->
      `Assoc [ ("team", `String (fst x)); ("puzzle", `String (snd x)) ]
      :: acc)
    [] solves

let get_all_solves _ =
  let* solves = Db.get_all_solves () in
  let solve_lst = unwrap solves |> serialize_solves in
  Lwt.return (Response.of_json (`List solve_lst))

let add_new_team req =
  let* req = read_form_data req in
  let name = List.assoc "team" req in
  let solves = List.assoc "solves" req |> int_of_string in
  let password = List.assoc "password" req in
  let* txn_result = Db.add_team name solves password in
  try
    unwrap txn_result;
    let team_json =
      (name, solves, password) |> Team.team_of_vals |> Team.yojson_of_t
    in
    Lwt.return (Response.of_json team_json)
  with
  | Failure exn -> str_response ?code:(Some 400) exn

(** [read_answers] returns a list of lines from the answers.txt file *)
let read_answers () =
  let lines = ref [] in
  let chan = open_in "resources/answers.txt" in
  try
    while true do
      lines := input_line chan :: !lines
    done;
    !lines
  with
  | End_of_file ->
      close_in chan;
      List.rev !lines

(** [create puzzle a] inserts a puzzle denoted "<name> <answer>", as
    [a], into the puzzles table*)
let create_puzzle a =
  let line = String.split_on_char ' ' a in
  Db.add_puzzle (List.hd line) (List.hd (List.rev line))

let fill_puzzle_table _ =
  try
    let answers = read_answers () in
    let rec insert_answers = function
      | [] -> failwith "answers file found empty"
      | [ a ] -> create_puzzle a
      | h :: t ->
          ignore (create_puzzle h);
          insert_answers t
    in
    ignore (insert_answers answers);
    str_response "puzzles loaded!"
  with
  | Failure exn -> str_response ?code:(Some 400) exn

let check_answer req =
  let* req = read_form_data req in
  let team = List.assoc "team" req in
  let puzzle = List.assoc "puzzle" req in
  let guess = List.assoc "guess" req in
  let* txn_result = Db.get_puzzle_answer_by_name puzzle in
  let answer = unwrap txn_result in
  match answer with
  | Some a ->
      if guess = a then
        let* add_txn = Db.add_solve team puzzle in
        try
          ignore (unwrap add_txn);
          str_response "correct"
        with
        | Failure _ ->
            str_response ?code:(Some 400)
              ("the team " ^ team ^ " does not exist")
      else str_response "incorrect"
  | None ->
      str_response ?code:(Some 400)
        ("the puzzle " ^ puzzle ^ " does not exist")

let login req =
  let* req = read_form_data req in
  let team = List.assoc "team" req in
  let password = List.assoc "password" req in
  let* txn_result = Db.get_team_password team in
  let correct_passwd = unwrap txn_result in
  match correct_passwd with
  | Some p ->
      if p = password then str_response "login successful"
      else str_response "password incorrect"
  | None ->
      ignore (Db.add_team team 0 password);
      str_response ?code:(Some 201) "new team created"

(** defines the routes of the API *)
let _ =
  App.empty
  |> App.get "/hello/" hello_world
  |> App.get "/teams/" get_all_teams
  |> App.get "/puzzles/" get_all_puzzles
  |> App.get "/solves/" get_all_solves
  |> App.get "/puzzles/fill/" fill_puzzle_table
  |> App.post "/team/new/" add_new_team
  |> App.post "/check/" check_answer
  |> App.post "/login/" login
  |> App.run_command
