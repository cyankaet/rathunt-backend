open OUnit2
open Database
open Lwt
open Lwt.Syntax
open OUnitLwt
open Types

let extract = function
  | Ok x -> x
  | Error (Db.Database_error exn) -> failwith exn

let clear_all_tables () =
  ignore (Db.clear_join ());
  ignore (Db.clear_puzzles ());
  ignore Db.clear_teams

(* empty db before starting testing *)
let () = clear_all_tables ()

let print_teams teams =
  List.fold_left (fun acc x -> Team.string_of_t x ^ acc) "" teams

let team_test name f expected_value =
  name
  >:: lwt_wrapper (fun _ ->
          (let* result = f in
           Lwt.return (extract result))
          >>= fun teams ->
          return
            (assert_equal ~printer:print_teams expected_value teams))

let add_test name (team : Team.t) =
  name
  >:: lwt_wrapper (fun _ ->
          (let* result =
             Db.add_team team.name team.solves team.password
           in
           Lwt.return (extract result))
          >>= fun teams -> return (assert_equal () teams))

let team_one =
  { Team.name = "test"; Team.solves = 0; Team.password = "passwd" }

let migrate_tests =
  [ (* team_test "starts with an empty database" (Db.get_all_teams ())
       []; add_test "add team one" team_one; team_test "adding a team
       means it's in the database" (Db.get_all_teams ()) [ team_one
       ]; *) ]

let suite =
  "test suite for rathunt backend" >::: List.flatten [ migrate_tests ]

let _ = run_test_tt_main suite
