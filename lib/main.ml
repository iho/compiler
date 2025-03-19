open Ast
let print_task = function
  | Notify s -> Printf.printf "Notify(\"%s\")" s
  | Log s -> Printf.printf "Log(\"%s\")" s
  | Alert s -> Printf.printf "Alert(\"%s\")" s

let rec print_expr indent = function
  | Task t -> Printf.printf "%sTask(" indent; print_task t; Printf.printf ")\n"
  | If (cond, then_branch, else_branch) ->
      Printf.printf "%sIf(\"%s\")\n" indent cond;
      List.iter (print_expr (indent ^ "  ")) then_branch;
      Printf.printf "%sElse\n" indent;
      List.iter (print_expr (indent ^ "  ")) else_branch

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