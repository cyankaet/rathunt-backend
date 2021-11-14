type team = {
  id : int;
  name : string;
  solves : int;
}

type error = Database_error of string

(* Migrations-related helper functions. *)
val migrate_teams : unit -> (unit, error) result Lwt.t

val migrate_puzzles : unit -> (unit, error) result Lwt.t

val migrate_join : unit -> (unit, error) result Lwt.t

val rollback : unit -> (unit, error) result Lwt.t

(* Core functions *)
val get_all : unit -> (team list, error) result Lwt.t

val add : string -> int -> (unit, error) result Lwt.t

val remove : int -> (unit, error) result Lwt.t

val clear : unit -> (unit, error) result Lwt.t