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
  let id = Router.param req "id" |> int_of_string in
  let person = { Person.content; id } |> Person.yojson_of_t in
  Lwt.return (Response.of_json person)

let print_first_todo req =
  let result =
    match Lwt.state (Db.get_all ()) with
    | Sleep -> failwith "sleeping?"
    | Return x -> x
    | Fail exn -> raise exn
  in
  let todos =
    match result with
    | Ok x -> x
    | Error (Database_error exn) -> failwith exn
  in
  let one = List.hd todos in
  let person =
    { Person.content = one.content; Person.id = one.id }
    |> Person.yojson_of_t
  in
  let resp = Response.of_json person in
  Lwt.return resp

let _ =
  App.empty
  |> App.get "/todo/all" print_first_todo
  |> App.get "/todo/:id/:name" print_person_handler
  |> App.run_command
