open Database.Routes
open Opium
(** defines the routes of the API *)
let _ =
  App.empty
  |> App.get "/hello/" hello_world
  |> App.get "/teams/" get_all_teams
  |> App.get "/solves/:name/" get_team_solves
  |> App.get "/puzzles/" get_all_puzzles
  |> App.get "/solves/" get_all_solves
  |> App.get "/puzzles/fill/" fill_puzzle_table
  |> App.post "/team/new/" add_new_team
  |> App.post "/check/" check_answer
  |> App.post "/login/" login
  |> App.run_command