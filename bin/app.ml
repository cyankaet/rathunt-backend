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
let hello_world _ =
  Lwt.return (Response.of_json (`String "hello, world!"))

let serialize_teams (teams : Team.t list) =
  List.fold_left (fun acc x -> Team.yojson_of_t x :: acc) [] teams

let get_all_teams _ =
  let* teams = Db.get_all_teams () in
  let team_lst = unwrap teams |> serialize_teams in
  Lwt.return (Response.of_json (`List team_lst))

let add_new_team req =
  let* req = read_form_data req in
  let name = List.assoc "team" req in
  let solves = List.assoc "solves" req |> int_of_string in
  let password = List.assoc "password" req in
  ignore (Db.add_team name solves password);
  let team_json =
    (name, solves, password) |> Team.team_of_vals |> Team.yojson_of_t
  in
  Lwt.return (Response.of_json team_json)

let _ =
  App.empty
  |> App.get "/hello/" hello_world
  |> App.get "/teams/" get_all_teams
  |> App.post "/team/new/" add_new_team
  |> App.run_command
