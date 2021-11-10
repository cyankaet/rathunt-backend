open Opium

module Person = struct
  type t = {
    id : int;
    content : string;
  }

  let yojson_of_t t =
    `Assoc [ ("name", `String t.content); ("id", `Int t.id) ]

  (* let t_of_yojson yojson = match yojson with | `Assoc [ ("name",
     `String name); ("age", `Int age) ] -> { name; age } | _ -> failwith
     "invalid person json" *)
end

let print_person_handler req =
  let content = Router.param req "content" in
  print_string "hello p";
  let id = Router.param req "id" |> int_of_string in
  let person = { Person.content; id } |> Person.yojson_of_t in
  Lwt.return (Response.of_json person)

let unwrap call =
  let result =
    match Lwt.state call with
    | Sleep -> failwith "sleeping?"
    | Return x -> x
    | Fail exn -> raise exn
  in
  match result with
  | Ok x -> x
  | Error (Db.Database_error exn) -> failwith exn

let get_all_db db = Lwt.return db

let print_first_todo req =
  let id = Router.param req "id" |> int_of_string in
  let todos = unwrap (Lwt.bind (Db.get_all ()) get_all_db) in
  let one = List.hd todos in
  let person =
    { Person.content = one.content; Person.id } |> Person.yojson_of_t
  in
  Lwt.return (Response.of_json person)

let _ =
  App.empty
  |> App.get "/todo/:id" print_first_todo
  |> App.get "/todo/:id/:content" print_person_handler
  |> App.run_command
