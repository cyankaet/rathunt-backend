open OUnit2

let migrate_tests = [ ("1+2 =3 " >:: fun _ -> assert_equal 3 (1 + 2)) ]

let suite =
  "test suite for rathunt backend" >::: List.flatten [ migrate_tests ]

let _ = run_test_tt_main suite
