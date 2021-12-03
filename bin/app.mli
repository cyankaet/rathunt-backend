open Opium

val get_all_teams : 'a -> Response.t Lwt.t
(** [get all teams] returns a JSON object with all the teams currently
    in the teams table *)
