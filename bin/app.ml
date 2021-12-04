open Opium
open Opium.Request
open Lwt.Syntax
open Database
open Database.Types

(** [unwrap obj] unwraps the result monad for database operation,
    returning the result if there is no exn, otherwise raising the
    exception*)
let unwrap = function
  | Ok x -> x
  | Error (Db.Database_error exn) -> failwith exn

let read_form_data req =
  let* req = to_multipart_form_data req in
  match req with
  | None -> failwith "no form data"
  | Some lst -> Lwt.return lst

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

let test_post req =
  let* req = read_form_data req in
  let name = List.assoc "team" req in
  let solves = List.assoc "solves" req |> int_of_string in
  let team = { Team.name; id = 3; Team.solves } |> Team.yojson_of_t in
  ignore (Db.add name solves);
  Lwt.return (Response.of_json team)

let _ =
  App.empty
  |> App.get "/team/:id/:name" print_team_handler
  |> App.get "/team/first" get_first_team
  |> App.get "/teams/" get_all_teams
  |> App.post "/team/post/" test_post
  |> App.run_command
