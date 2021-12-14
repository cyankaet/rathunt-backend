open OUnit2
open Database
open Lwt
open Lwt.Syntax
open OUnitLwt

let () =
  ignore (Db.clear_join ());
  ignore (Db.clear_puzzles ());
  ignore (Db.clear_teams ())

let extract = function
  | Ok x -> x
  | Error (Db.Database_error exn) -> failwith exn

let migrate_tests =
  [
    "starts with an empty database"
    >:: lwt_wrapper (fun _ ->
            (let* result = Db.get_all_teams () in
             Lwt.return (extract result))
            >>= fun teams -> return (assert_equal [] teams));
  ]

(* example: "SimpleAssertion" >:: (lwt_wrapper (fun ctxt -> Lwt.return 4
   >>= fun i -> Lwt.return (assert_equal ~ctxt 4 i))) *)
let suite =
  "test suite for rathunt backend" >::: List.flatten [ migrate_tests ]

let _ = run_test_tt_main suite
