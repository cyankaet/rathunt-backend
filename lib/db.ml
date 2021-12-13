include Types.Team
include Types.Puzzle

(** url of local PostgreSQL database to be used for all transactions *)
let connection_url = Unix.getenv "DATABASE_URL"

(** This is the connection pool we will use for executing DB operations. *)
let pool =
  match
    Caqti_lwt.connect_pool ~max_size:10 (Uri.of_string connection_url)
  with
  | Ok pool -> pool
  | Error err -> failwith (Caqti_error.show err)

type team = Types.Team.t
type puzzle = Types.Puzzle.t
type error = Database_error of string

(** Helper method to map Caqti errors to our own error type. val
    or_error : ('a, [> Caqti_error.t ]) result Lwt.t -> ('a, error)
    result Lwt.t *)
let or_error m =
  match%lwt m with
  | Ok a -> Ok a |> Lwt.return
  | Error e -> Error (Database_error (Caqti_error.show e)) |> Lwt.return

let migrate_team_table =
  Caqti_request.exec Caqti_type.unit
    {| CREATE TABLE teams (
            name VARCHAR NOT NULL UNIQUE PRIMARY KEY,
            solves INTEGER,
            password VARCHAR
         )
      |}

let migrate_puzzle_table =
  Caqti_request.exec Caqti_type.unit
    {| CREATE TABLE puzzles (
            name VARCHAR NOT NULL UNIQUE PRIMARY KEY,
            answer VARCHAR
          )
      |}

(** Caqti request with SQL to create puzteam table *)
let migrate_team_puzzle_join =
  Caqti_request.exec Caqti_type.unit
    {| CREATE TABLE puzteam (
          id SERIAL NOT NULL PRIMARY KEY,
          team_id VARCHAR NOT NULL,  
          puzzle_id VARCHAR NOT NULL,  
          FOREIGN KEY(team_id) REFERENCES teams(name),
          FOREIGN KEY(puzzle_id) REFERENCES puzzles(name)
        )
    |}

let migrate migrate_table =
  let migrate' (module C : Caqti_lwt.CONNECTION) =
    C.exec migrate_table ()
  in
  Caqti_lwt.Pool.use migrate' pool |> or_error

let migrate_teams () = migrate migrate_team_table
let migrate_puzzles () = migrate migrate_puzzle_table
let migrate_join () = migrate migrate_team_puzzle_join

let rollback name =
  let rollback' (module C : Caqti_lwt.CONNECTION) =
    C.exec
      (Caqti_request.exec Caqti_type.unit ("DROP TABLE " ^ name))
      ()
  in
  Caqti_lwt.Pool.use rollback' pool |> or_error

let rollback_teams () = rollback "teams"
let rollback_join () = rollback "puzteam"
let rollback_puzzles () = rollback "puzzles"

let get_all_teams () =
  let get_all' (module C : Caqti_lwt.CONNECTION) =
    C.fold
      (Caqti_request.collect Caqti_type.unit
         Caqti_type.(tup3 string int string)
         "SELECT name, solves, password FROM teams")
      (fun (name, solves, password) acc ->
        { name; solves; password } :: acc)
      () []
  in
  Caqti_lwt.Pool.use get_all' pool |> or_error

let get_all_puzzles () =
  let get_all' (module C : Caqti_lwt.CONNECTION) =
    C.fold
      (Caqti_request.collect Caqti_type.unit
         Caqti_type.(tup2 string string)
         "SELECT name, answer FROM puzzles")
      (fun (name, answer) acc -> { name; answer } :: acc)
      () []
  in
  Caqti_lwt.Pool.use get_all' pool |> or_error

let get_all_solves () =
  let get_all' (module C : Caqti_lwt.CONNECTION) =
    C.fold
      (Caqti_request.collect Caqti_type.unit
         Caqti_type.(tup2 string string)
         "SELECT team_id, puzzle_id FROM puzteam")
      (fun (team, puzzle) acc -> (team, puzzle) :: acc)
      () []
  in
  Caqti_lwt.Pool.use get_all' pool |> or_error

let get_puzzle_answer_by_name puzzle =
  let get_puzzle' puz (module C : Caqti_lwt.CONNECTION) =
    C.find_opt
      (Caqti_request.find_opt
         Caqti_type.(string)
         Caqti_type.(string)
         "SELECT answer FROM puzzles WHERE name = ?")
      puz
  in
  Caqti_lwt.Pool.use (get_puzzle' puzzle) pool |> or_error

let get_team_password team =
  let get_team' login (module C : Caqti_lwt.CONNECTION) =
    C.find_opt
      (Caqti_request.find_opt
         Caqti_type.(string)
         Caqti_type.(string)
         "SELECT password FROM teams WHERE name = ?")
      login
  in
  Caqti_lwt.Pool.use (get_team' team) pool |> or_error

let add_team name solves passwd =
  let add' team (module C : Caqti_lwt.CONNECTION) =
    C.exec
      (Caqti_request.exec
         Caqti_type.(tup3 string int string)
         "INSERT INTO teams (name, solves, password) VALUES (?, ?, ?)")
      team
  in
  Caqti_lwt.Pool.use (add' (name, solves, passwd)) pool |> or_error

let add_puzzle name answer =
  let add' team (module C : Caqti_lwt.CONNECTION) =
    C.exec
      (Caqti_request.exec
         Caqti_type.(tup2 string string)
         "INSERT INTO puzzles (name, answer) VALUES (?, ?)")
      team
  in
  Caqti_lwt.Pool.use (add' (name, answer)) pool |> or_error

let add_solve team_id puzzle_id =
  let add' team (module C : Caqti_lwt.CONNECTION) =
    C.exec
      (Caqti_request.exec
         Caqti_type.(tup2 string string)
         "INSERT INTO puzteam (team_id, puzzle_id) VALUES (?, ?)")
      team
  in
  Caqti_lwt.Pool.use (add' (team_id, puzzle_id)) pool |> or_error

let clear name =
  let clear' (module C : Caqti_lwt.CONNECTION) =
    C.exec
      (Caqti_request.exec Caqti_type.unit ("TRUNCATE TABLE " ^ name))
      ()
  in
  Caqti_lwt.Pool.use clear' pool |> or_error

let clear_teams () = clear "teams"
let clear_puzzles () = clear "puzzles"
let clear_join () = clear "puzteam"