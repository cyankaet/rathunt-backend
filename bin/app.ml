open Opium
open Lwt.Syntax
open Database
open Database.Types

(** [unwrap obj] unwraps the result monad for database operation,
    returning the result if there is no exn, otherwise raising the
    exception*)
let unwrap = function
  | Ok x -> x
  | Error (Db.Database_error exn) -> failwith exn

(* litmus test for whether the API is working at all, returns the inputs
   you passed and solves = 0 *)
let print_team_handler req =
  let name = Router.param req "name" in
  let id = Router.param req "id" |> int_of_string in
  let team = { Team.name; id; solves = 0 } |> Team.yojson_of_t in
  Lwt.return (Response.of_json team)

(* prints first team in database*)
let get_first_team _ =
  let* teams = Db.get_all () in
  let one = List.hd (unwrap teams) in
  let person = one |> Team.yojson_of_t in
  Lwt.return (Response.of_json person)

let serialize_teams (teams : Team.t list) =
  List.fold_left (fun acc x -> Team.yojson_of_t x :: acc) [] teams

let get_all_teams _ =
  let* teams = Db.get_all () in
  let team_lst = unwrap teams |> serialize_teams in
  Lwt.return (Response.of_json (`List team_lst))

let _ =
  App.empty
  |> App.get "/team/:id/:name" print_team_handler
  |> App.get "/team/first" get_first_team
  |> App.get "/teams/" get_all_teams
  |> App.run_command
