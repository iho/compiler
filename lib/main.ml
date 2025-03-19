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

let generate_python_task task =
  match task with
  | Notify s -> Printf.sprintf "print(\"%s\")" s
  | Log s -> Printf.sprintf "print(\"LOG: %s\")" s
  | Alert s -> Printf.sprintf "print(\"ALERT: %s\")" s
  | Fetch (url, var) -> 
      Printf.sprintf "%s = requests.get(\"%s\").json()" var url
  | Write (content, file) -> 
      Printf.sprintf "with open(\"%s\", 'w') as f: json.dump(%s, f)" file content
  | Read (file, var) -> 
      Printf.sprintf "with open(\"%s\", 'r') as f: %s = json.load(f)" file var

let rec generate_python_expr indent expr =
  match expr with
  | Task t -> Printf.sprintf "%s%s\n" indent (generate_python_task t)
  | If (cond, then_branch, else_branch) ->
      let then_code = String.concat "" (List.map (generate_python_expr (indent ^ "    ")) then_branch) in
      let else_code = String.concat "" (List.map (generate_python_expr (indent ^ "    ")) else_branch) in
      Printf.sprintf "%sif %s:\n%s%selse:\n%s" indent cond then_code indent else_code
  | Repeat (times, body) ->
      let body_code = String.concat "" (List.map (generate_python_expr (indent ^ "    ")) body) in
      Printf.sprintf "%sfor _ in range(%d):\n%s" indent times body_code
  | While (cond, body) ->
      let body_code = String.concat "" (List.map (generate_python_expr (indent ^ "    ")) body) in
      Printf.sprintf "%swhile %s:\n%s" indent cond body_code
  | Wait secs -> Printf.sprintf "%stime.sleep(%d)\n" indent secs
  | Set (var, value) -> Printf.sprintf "%s%s = %d\n" indent var value
  | Add (value, var) -> Printf.sprintf "%s%s += %d\n" indent var value
  | Subtract (value, var) -> Printf.sprintf "%s%s -= %d\n" indent var value
  | Parallel body ->
      let body_code = String.concat "" (List.map (generate_python_expr (indent ^ "    ")) body) in
      Printf.sprintf "%s# Parallel execution (Python doesn't support true parallelism in this context)\n%s" indent body_code
  | Try (try_block, catch_block) ->
      let try_code = String.concat "" (List.map (generate_python_expr (indent ^ "    ")) try_block) in
      let catch_code = String.concat "" (List.map (generate_python_expr (indent ^ "    ")) catch_block) in
      Printf.sprintf "%stry:\n%s%sexcept Exception as e:\n%s" indent try_code indent catch_code
  | Stop -> Printf.sprintf "%ssys.exit(0)\n" indent

let generate_python_program prog =
  let imports = "import json\nimport requests\nimport time\nimport sys\n\n" in
  let body = String.concat "" (List.map (generate_python_expr "") prog) in
  imports ^ body

let () =
  let lexbuf = Lexing.from_channel stdin in
  try
    let ast = Parser.program Lexer.token lexbuf in
    print_program ast;
    Printf.printf "\nGenerated Python code:\n%s\n" (generate_python_program ast)
  with
  | Lexer.Lexing_error msg -> Printf.eprintf "Lexer error: %s\n" msg
  | Parser.Error -> Printf.eprintf "Parse error at position %d\n" (Lexing.lexeme_start lexbuf) 