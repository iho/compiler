open Ast

let print_task = function
  | Notify s -> Printf.printf "Notify(\"%s\")" s
  | Log s -> Printf.printf "Log(\"%s\")" s
  | Alert s -> Printf.printf "Alert(\"%s\")" s
  | Fetch (url, var) -> Printf.printf "Fetch(\"%s\", \"%s\")" url var
  | Write (content, file) -> Printf.printf "Write(\"%s\", \"%s\")" content file
  | Read (file, var) -> Printf.printf "Read(\"%s\", \"%s\")" file var

let rec print_expr indent = function
  | Task t -> Printf.printf "%sTask(" indent; print_task t; Printf.printf ")\n"
  | If (cond, then_branch, else_branch) ->
      Printf.printf "%sIf(\"%s\")\n" indent cond;
      List.iter (print_expr (indent ^ "  ")) then_branch;
      Printf.printf "%sElse\n" indent;
      List.iter (print_expr (indent ^ "  ")) else_branch
  | Repeat (times, body) ->
      Printf.printf "%sRepeat(%d times)\n" indent times;
      List.iter (print_expr (indent ^ "  ")) body
  | While (cond, body) ->
      Printf.printf "%sWhile(\"%s\")\n" indent cond;
      List.iter (print_expr (indent ^ "  ")) body
  | Wait secs -> Printf.printf "%sWait(%d seconds)\n" indent secs
  | Set (var, value) -> Printf.printf "%sSet(\"%s\", %d)\n" indent var value
  | Add (value, var) -> Printf.printf "%sAdd(%d to \"%s\")\n" indent value var
  | Subtract (value, var) -> Printf.printf "%sSubtract(%d from \"%s\")\n" indent value var
  | Parallel body ->
      Printf.printf "%sParallel\n" indent;
      List.iter (print_expr (indent ^ "  ")) body
  | Try (try_block, catch_block) ->
      Printf.printf "%sTry\n" indent;
      List.iter (print_expr (indent ^ "  ")) try_block;
      Printf.printf "%sCatch\n" indent;
      List.iter (print_expr (indent ^ "  ")) catch_block
  | Stop -> Printf.printf "%sStop\n" indent

let print_program prog =
  Printf.printf "Program:\n";
  List.iter (print_expr "  ") prog

let get_indent level = String.make (level * 4) ' '

let generate_python_task level task =
  let indent = get_indent level in
  match task with
  | Notify s -> Printf.sprintf "%sprint(\"%s\")" indent s
  | Log s -> Printf.sprintf "%sprint(\"LOG: %s\")" indent s
  | Alert s -> Printf.sprintf "%sprint(\"ALERT: %s\")" indent s
  | Fetch (url, var) -> 
      Printf.sprintf "%s%s = await session.get(\"%s\")\n%s%s = await %s.json()" indent var url indent var var
  | Write (content, file) -> 
      let inner_indent = get_indent (level + 1) in
      Printf.sprintf "%swith open(\"%s\", 'w') as f:\n%sjson.dump(%s, f)" indent file inner_indent content
  | Read (file, var) -> 
      let inner_indent = get_indent (level + 1) in
      Printf.sprintf "%swith open(\"%s\", 'r') as f:\n%s%s = json.load(f)" indent file inner_indent var

let rec generate_python_expr level expr =
  let indent = get_indent level in
  match expr with
  | Task t -> generate_python_task level t ^ "\n"
  | If (cond, then_branch, else_branch) ->
      let then_code = String.concat "" (List.map (generate_python_expr (level + 1)) then_branch) in
      let else_code = String.concat "" (List.map (generate_python_expr (level + 1)) else_branch) in
      Printf.sprintf "%sif %s:\n%s%selse:\n%s" indent cond then_code indent else_code
  | Repeat (times, body) ->
      let body_code = String.concat "" (List.map (generate_python_expr (level + 1)) body) in
      Printf.sprintf "%sfor _ in range(%d):\n%s" indent times body_code
  | While (cond, body) ->
      let body_code = String.concat "" (List.map (generate_python_expr (level + 1)) body) in
      Printf.sprintf "%swhile %s:\n%s" indent cond body_code
  | Wait secs -> Printf.sprintf "%sawait asyncio.sleep(%d)\n" indent secs
  | Set (var, value) -> Printf.sprintf "%s%s = %d\n" indent var value
  | Add (value, var) -> Printf.sprintf "%s%s += %d\n" indent var value
  | Subtract (value, var) -> Printf.sprintf "%s%s -= %d\n" indent var value
  | Parallel body ->
      let inner_indent = get_indent (level + 1) in
      let task_functions = List.mapi (fun i expr -> 
        let task_name = Printf.sprintf "task_%d" i in
        let function_body = 
          match expr with
          | Task t -> 
              let content = generate_python_task 0 t in
              Printf.sprintf "%s%s" inner_indent content
          | Wait secs -> Printf.sprintf "%sawait asyncio.sleep(%d)" inner_indent secs
          | _ -> 
              let content = generate_python_expr 0 expr in
              let content_trimmed = 
                if String.length content > 0 && content.[String.length content - 1] = '\n' then
                  String.sub content 0 (String.length content - 1)
                else 
                  content 
              in
              Printf.sprintf "%s%s" inner_indent content_trimmed
        in
        Printf.sprintf "%sasync def %s():\n%s" indent task_name function_body
      ) body in
      let task_calls = List.mapi (fun i _ -> 
        Printf.sprintf "%s%s()" inner_indent (Printf.sprintf "task_%d" i)
      ) body in
      Printf.sprintf "%s# Run tasks in parallel\n%s\n%sawait asyncio.gather(\n%s\n%s)\n" 
        indent
        (String.concat "\n" task_functions)
        indent
        (String.concat ",\n" task_calls)
        indent
  | Try (try_block, catch_block) ->
      let try_code = String.concat "" (List.map (generate_python_expr (level + 1)) try_block) in
      let catch_code = String.concat "" (List.map (generate_python_expr (level + 1)) catch_block) in
      Printf.sprintf "%stry:\n%s%sexcept Exception as e:\n%s" indent try_code indent catch_code
  | Stop -> Printf.sprintf "%ssys.exit(0)\n" indent

let generate_python_program prog =
  let imports = "import json\nimport asyncio\nimport aiohttp\nimport sys\n\n" in
  let main_function = "async def main():\n    async with aiohttp.ClientSession() as session:\n" in
  let body = String.concat "" (List.map (generate_python_expr 2) prog) in
  let run_code = "\nif __name__ == '__main__':\n    asyncio.run(main())\n" in
  imports ^ main_function ^ body ^ run_code

let () =
  let lexbuf = Lexing.from_channel stdin in
  try
    let ast = Parser.program Lexer.token lexbuf in
    print_program ast;
    Printf.printf "\nGenerated Python code:\n%s\n" (generate_python_program ast)
  with
  | Lexer.Lexing_error msg -> Printf.eprintf "Lexer error: %s\n" msg
  | Parser.Error -> Printf.eprintf "Parse error at position %d\n" (Lexing.lexeme_start lexbuf) 