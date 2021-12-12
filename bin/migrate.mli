val migrate_team : unit -> unit Lwt.t
(** [migrate_team ()] creates the teams table from the local database
    specified by environment variable [DATABASE_URL]. Raises
    [Db.Database_error] if there is some issue with the SQL transaction*)

val migrate_puzzles : unit -> unit Lwt.t
(** [migrate_puzzles ()] creates the puzzles table from the local
    database specified by environment variable [DATABASE_URL]. Raises
    [Db.Database_error] if there is some issue with the SQL transaction*)

val migrate_join : unit -> unit Lwt.t
(** [migrate_join ()] creates the puzteam table from the local database
    specified by environment variable [DATABASE_URL]. Raises
    [Db.Database_error] if there is some issue with the SQL transaction*)