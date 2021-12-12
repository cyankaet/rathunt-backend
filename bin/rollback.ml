open Database

let rollback_team () =
  print_endline "Dropping teams table.";
  match%lwt Db.rollback_teams () with
  | Ok () -> print_endline "Done." |> Lwt.return
  | Error (Db.Database_error msg) -> print_endline msg |> Lwt.return

let rollback_puzzles () =
  print_endline "Dropping puzzles table.";
  match%lwt Db.rollback_puzzles () with
  | Ok () -> print_endline "Done." |> Lwt.return
  | Error (Db.Database_error msg) -> print_endline msg |> Lwt.return

let rollback_join () =
  print_endline "Dropping join table.";
  match%lwt Db.rollback_join () with
  | Ok () -> print_endline "Done." |> Lwt.return
  | Error (Db.Database_error msg) -> print_endline msg |> Lwt.return

(** rolls back / deletes all three tables (teams, puzzles, puzteam) to
    the local database.*)
let () =
  Lwt_main.run (rollback_join ());
  Lwt_main.run (rollback_team ());
  Lwt_main.run (rollback_puzzles ())
