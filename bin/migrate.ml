open Database

let migrate_team () =
  print_endline "Creating teams table.";
  match%lwt Db.migrate_teams () with
  | Ok () -> print_endline "Done." |> Lwt.return
  | Error (Db.Database_error msg) -> print_endline msg |> Lwt.return

let migrate_puzzles () =
  print_endline "Creating puzzles table.";
  match%lwt Db.migrate_puzzles () with
  | Ok () -> print_endline "Done." |> Lwt.return
  | Error (Db.Database_error msg) -> print_endline msg |> Lwt.return

let migrate_join () =
  print_endline "Creating join table.";
  match%lwt Db.migrate_join () with
  | Ok () -> print_endline "Done." |> Lwt.return
  | Error (Db.Database_error msg) -> print_endline msg |> Lwt.return

(** migrates all three tables (teams, puzzles, puzteam) to the local
    database*)
let () =
  Lwt_main.run (migrate_team ());
  Lwt_main.run (migrate_puzzles ());
  Lwt_main.run (migrate_join ())
