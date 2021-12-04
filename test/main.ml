open OUnit2

let migrate_tests = [ ("1+2 =3 " >:: fun _ -> assert_equal 3 (1 + 2)) ]

(** note to future implementers: we need to make this test suite
    agnostic to current local postgres db. for this reason, we need to
    clear the db and add the contents for testing manually before we run
    tests on those things. probably the best way to do this without
    implementing complicated delete/cascade ops is just to rollback and
    re-migrate the three tables at the beginning of each run. this can
    be added to the make test target?*)
let suite =
  "test suite for rathunt backend" >::: List.flatten [ migrate_tests ]

let _ = run_test_tt_main suite
