open Opium
open Lwt.Syntax
open Database
open Database.Types

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
let print_first_team _ =
  let* todos = Db.get_all () in
  let one = List.hd (unwrap todos) in
  let person =
    { Team.name = one.name; Team.id = one.id; Team.solves = one.solves }
    |> Team.yojson_of_t
  in
  Lwt.return (Response.of_json person)

let _ =
  App.empty
  |> App.get "/team/:id/:name" print_team_handler
  |> App.get "/team/first" print_first_team
  |> App.run_command
