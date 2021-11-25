include Types.Team
include Types.Puzzle

let connection_url = "postgresql://kaet@localhost:5432/rat"

(* This is the connection pool we will use for executing DB
   operations. *)
let pool =
  match
    Caqti_lwt.connect_pool ~max_size:10 (Uri.of_string connection_url)
  with
  | Ok pool -> pool
  | Error err -> failwith (Caqti_error.show err)

type team = Types.Team.t

type error = Database_error of string

(* Helper method to map Caqti errors to our own error type. val or_error
   : ('a, [> Caqti_error.t ]) result Lwt.t -> ('a, error) result
   Lwt.t *)
let or_error m =
  match%lwt m with
  | Ok a -> Ok a |> Lwt.return
  | Error e -> Error (Database_error (Caqti_error.show e)) |> Lwt.return

let migrate_team_table =
  Caqti_request.exec Caqti_type.unit
    {| CREATE TABLE teams (
            id SERIAL NOT NULL PRIMARY KEY,
            name VARCHAR,
            solves INTEGER
         )
      |}

let migrate_puzzle_table =
  Caqti_request.exec Caqti_type.unit
    {| CREATE TABLE puzzles (
            id SERIAL NOT NULL PRIMARY KEY,
            name VARCHAR
          )
      |}

let migrate_team_puzzle_join =
  Caqti_request.exec Caqti_type.unit
    {| CREATE TABLE puzzles (
          id INTEGER NOT NULL PRIMARY KEY,
          team_id INTEGER NOT NULL,  
          puzzle_id INTEGER NOT NULL,  
          FOREIGN KEY team_id REFERENCES teams(id),
          FOREIGN KEY puzzle_id REFERENCES puzzles(id)
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

let rollback_query =
  Caqti_request.exec Caqti_type.unit "DROP TABLE teams"

let rollback () =
  let rollback' (module C : Caqti_lwt.CONNECTION) =
    C.exec rollback_query ()
  in
  Caqti_lwt.Pool.use rollback' pool |> or_error

let get_all_query =
  Caqti_request.collect Caqti_type.unit
    Caqti_type.(tup3 int string int)
    "SELECT id, name, solves FROM teams"

let get_all () =
  let get_all' (module C : Caqti_lwt.CONNECTION) =
    C.fold get_all_query
      (fun (id, name, solves) acc -> { id; name; solves } :: acc)
      () []
  in
  Caqti_lwt.Pool.use get_all' pool |> or_error

let add_query =
  Caqti_request.exec
    Caqti_type.(tup2 string int)
    "INSERT INTO teams (name, solves) VALUES (?, ?)"

let add name solves =
  let add' team (module C : Caqti_lwt.CONNECTION) =
    C.exec add_query team
  in
  Caqti_lwt.Pool.use (add' (name, solves)) pool |> or_error

let remove_query =
  Caqti_request.exec Caqti_type.int "DELETE FROM teams WHERE id = ?"

let remove id =
  let remove' id (module C : Caqti_lwt.CONNECTION) =
    C.exec remove_query id
  in
  Caqti_lwt.Pool.use (remove' id) pool |> or_error

let clear_query =
  Caqti_request.exec Caqti_type.unit "TRUNCATE TABLE teams"

let clear () =
  let clear' (module C : Caqti_lwt.CONNECTION) =
    C.exec clear_query ()
  in
  Caqti_lwt.Pool.use clear' pool |> or_error