(** Defines the routes of the API *)

open Opium

val hello_world : 'a -> Response.t Lwt.t
(** [hello_world] returns the string "hello, world" wrapped in a JSON.
    Intended to test if the API is functioning.*)

val get_all_teams : 'a -> Response.t Lwt.t
(** [get_all_teams] returns a JSON object with all the teams currently
    in the teams table. API: JSON is a list of JSONs, all containing
    "name" and "solves" fields.*)

val add_new_team : Request.t -> Response.t Lwt.t
(** [add_new_team req] takes a FormData HTTP POST request [req] and
    inserts the specified team in the table. API: Expects "name" :
    string, "solves" : int, "password" : string keys where "name" and
    "password" contain only alphanumeric or symbol (!\@#) characters.*)

val fill_puzzle_table : 'a -> Response.t Lwt.t
(** [fill_puzzle_table] prompts the application to load in a
    serverside-asset and autofill the puzzle table with puzzles*)
