(** Interface for all local database interactions

    This module represents the tables held in the PostgreSQL database.
    It handles migration and rollback of tables, clearing tables,
    inserting rows, and querying the data *)

type team = Types.Team.t
(** internal representation of team type through application *)

type puzzle = Types.Puzzle.t
(** internal representation of puzzle type through application *)

type error =
  | Database_error of string
      (** error thrown for issues with SQL interactions with database *)

(* migrations-related functions *)
val migrate_teams : unit -> (unit, error) result Lwt.t
(** [migrate_teams ()] creates the teams table from the local database
    specified by environment variable [DATABASE_URL]. Raises
    [Database_error] if there is some issue with the SQL transaction*)

val migrate_puzzles : unit -> (unit, error) result Lwt.t
(** [migrate_puzzles ()] creates the puzzles table from the local
    database specified by environment variable [DATABASE_URL]. Raises
    [Database_error] if there is some issue with the SQL transaction *)

val migrate_join : unit -> (unit, error) result Lwt.t
(** [migrate_join ()] creates the puzteam table from the local database
    specified by environment variable [DATABASE_URL]. Raises
    [Database_error] if there is some issue with the SQL transaction *)

val rollback_teams : unit -> (unit, error) result Lwt.t
(** [rollback_teams ()] deletes the teams table from the local database
    specified by environment variable [DATABASE_URL]. Returns
    [Database_error] if there is some issue with the SQL transaction *)

val rollback_join : unit -> (unit, error) result Lwt.t
(** [rollback_join ()] deletes the puzteam table from the local database
    specified by environment variable [DATABASE_URL]. Returns
    [Database_error] if there is some issue with the SQL transaction *)

val rollback_puzzles : unit -> (unit, error) result Lwt.t
(** [rollback_puzzles ()] deletes the puzzles table from the local
    database specified by environment variable [DATABASE_URL]. Returns
    [Database_error] if there is some issue with the SQL transaction *)

(* table interactions *)
val get_all_teams : unit -> (team list, error) result Lwt.t
(** [get_all_teams ()] returns a list of all the teams and their data
    currently in the teams table in local database specified by
    [$DATABASE_URL], corresponding to the team type *)

val get_all_puzzles : unit -> (puzzle list, error) result Lwt.t
(** [get_all_puzzles ()] returns a list of all the puzzles and their
    data currently in the puzzles table in local database specified by
    [$DATABASE_URL], corresponding to the puzzle type *)

val get_all_solves :
  unit -> ((string * string) list, error) result Lwt.t
(** [get_all_solves ()] returns a list of pairs of teams and puzzles
    they have solved from the puzteam table in local database specified
    by [$DATABASE_URL] - that is, each pair represents one 'solve' where
    (team, puzzle) means team has solved puzzle.*)

val get_puzzle_answer_by_name :
  string -> (string option, error) result Lwt.t
(** [get_puzzle_answer_by_name puzzle] returns the answer (if there is
    one) to the first puzzle that matches the provided name [puzzle] in
    the puzzles table in local database specified by [$DATABASE_URL]*)

val get_team_password : string -> (string option, error) result Lwt.t
(** [get_team_with_password team] returns the password corresponding to
    the team [team] (if there is one) from the teams table in local
    database specified by [$DATABASE_URL] *)

val get_puzzles_by_team : string -> (string list, error) result Lwt.t
(** [get_puzzles_by_team team] returns a list of solved puzzles for the
    team [team] from the pairs in the puzteam table in local database
    specified by [$DATABASE_URL]*)

val add_team : string -> int -> string -> (unit, error) result Lwt.t
(** [add_team name solves password] inserts a new team into the teams
    table in the local database specified by [$DATABASE_URL] with name
    field [name], number of solves [solves], and password field
    [password]. Returns [Database_error] if there is some issue with the
    SQL transaction - frequently duplicate key error when the same
    username is attempted to register multiple times *)

val add_puzzle : string -> string -> (unit, error) result Lwt.t
(** [add_puzzle name answer] inserts a new puzzle into the puzzles table
    in the local database specified by [$DATABASE_URL] with name field
    [name] and answer field [password]. Returns [Database_error] if
    there is some issue with the SQL transaction - frequently duplicate
    key error when the same puzzle name is attempted to insert multiple
    times *)

val add_solve : string -> string -> (unit, error) result Lwt.t
(** [add_solve team puzzle] inserts a new 'solve' into the puzteam join
    table in the local database specified by [$DATABASE_URL] that
    relates the team to the puzzle, expressing that that team has solved
    that puzzle. Returns [Database_error] if there is some issue with
    the SQL transaction *)

val increment_solves : string -> (unit, error) result Lwt.t
(** [increment_solves solves team] increments a team [team]'s solve
    count in the teams table in the local database specified by
    [$DATABASE_URL]. Returns [Database_error] if there is some issue
    with the SQL transaction *)

val clear_teams : unit -> (unit, error) result Lwt.t
(** [clear_teams ()] empties the teams table in the local database
    specified by [$DATABASE_URL]. Note that this should not be run
    without first emptying the join table due to dependencies. Returns
    [Database_error] if there is some issue with the SQL transaction*)

val clear_puzzles : unit -> (unit, error) result Lwt.t
(** [clear_puzzles ()] empties the puzzles table in the local database
    specified by [$DATABASE_URL]. Note that this should not be run
    without first emptying the join table due to dependencies. Returns
    [Database_error] if there is some issue with the SQL transaction*)

val clear_join : unit -> (unit, error) result Lwt.t
(** [clear_join ()] empties the puzteam table in the local database
    specified by [$DATABASE_URL]. Returns [Database_error] if there is
    some issue with the SQL transaction *)
