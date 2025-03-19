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

let () =
  let lexbuf = Lexing.from_channel stdin in
  try
    let ast = Parser.program Lexer.token lexbuf in
    print_program ast
  with
  | Lexer.Lexing_error msg -> Printf.eprintf "Lexer error: %s\n" msg
  | Parser.Error -> Printf.eprintf "Parse error at position %d\n" (Lexing.lexeme_start lexbuf) 