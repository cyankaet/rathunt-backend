type team = Types.Team.t

type error = Database_error of string

(* Migrations-related helper functions. *)
val migrate_teams : unit -> (unit, error) result Lwt.t

val migrate_puzzles : unit -> (unit, error) result Lwt.t

val migrate_join : unit -> (unit, error) result Lwt.t

val rollback_teams : unit -> (unit, error) result Lwt.t

val rollback_join : unit -> (unit, error) result Lwt.t

val rollback_puzzles : unit -> (unit, error) result Lwt.t

(* Core functions *)
val get_all_teams : unit -> (team list, error) result Lwt.t

val add_team : string -> int -> (int, error) result Lwt.t

val add_puzzle : string -> string -> (unit, error) result Lwt.t

val add_solve : int -> int -> (unit, error) result Lwt.t

val remove : int -> (unit, error) result Lwt.t

val clear : unit -> (unit, error) result Lwt.t