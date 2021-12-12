val rollback_team : unit -> unit Lwt.t
(** [rollback_team ()] deletes the teams table from the local database
    specified by environment variable [DATABASE_URL]. Raises
    [Db.Database_error] if there is some issue with the SQL transaction*)

val rollback_puzzles : unit -> unit Lwt.t
(** [rollback_puzzles ()] deletes the puzzles table from the local
    database specified by environment variable [DATABASE_URL]. Raises
    [Db.Database_error] if there is some issue with the SQL transaction*)

val rollback_join : unit -> unit Lwt.t
(** [rollback_join ()] deletes the puzteam table from the local database
    specified by environment variable [DATABASE_URL]. Raises
    [Db.Database_error] if there is some issue with the SQL transaction*)