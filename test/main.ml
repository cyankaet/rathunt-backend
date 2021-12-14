open OUnit2
open Database
open Lwt
open Lwt.Syntax
open OUnitLwt
open Types

let extract = function
  | Ok x -> x
  | Error (Db.Database_error exn) -> failwith exn

let () =
  ignore
    (let* result = Db.clear_join () in
     extract result;
     let* result = Db.clear_puzzles () in
     extract result;
     Db.clear_teams ())

let print_teams teams =
  List.fold_left (fun acc x -> Team.string_of_t x ^ acc) "" teams

let migrate_tests =
  [
    "starts with an empty database"
    >:: lwt_wrapper (fun _ ->
            (let* result = Db.get_all_teams () in
             Lwt.return (extract result))
            >>= fun teams ->
            return (assert_equal ~printer:print_teams [] teams));
  ]

(* example: "SimpleAssertion" >:: (lwt_wrapper (fun ctxt -> Lwt.return 4
   >>= fun i -> Lwt.return (assert_equal ~ctxt 4 i))) *)
let suite =
  "test suite for rathunt backend" >::: List.flatten [ migrate_tests ]

let _ = run_test_tt_main suite
