{
open Parser
exception Lexing_error of string
}

let whitespace = [' ' '\t' '\n']+
let string = '"' [^ '"']* '"'

rule token = parse
  | whitespace    { token lexbuf }
  | "START"       { START }
  | "END"         { END }
  | "TASK"        { TASK }
  | "IF"          { IF }
  | "ELSE"        { ELSE }
  | "ENDIF"       { ENDIF }
  | "condition"   { CONDITION }
  | "notify"      { NOTIFY }
  | "log"         { LOG }
  | "alert"       { ALERT }
  | string as s   { STRING (String.sub s 1 (String.length s - 2)) }
  | eof           { EOF }
  | _             { raise (Lexing_error ("Unknown token: " ^ Lexing.lexeme lexbuf)) } 