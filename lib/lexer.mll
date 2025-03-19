{
open Parser
exception Lexing_error of string
}

let whitespace = [' ' '\t' '\n']+
let string = '"' [^ '"']* '"'
let number = ['0'-'9']+
let var_interp = '\\' '$' '{' [^ '}']+ '}'

rule token = parse
  | "REPEAT"      { REPEAT }
  | "ENDREPEAT"   { ENDREPEAT }
  | "WHILE"       { WHILE }
  | "ENDWHILE"    { ENDWHILE }
  | "WAIT"        { WAIT }
  | "SECONDS"     { SECONDS }
  | "SET"         { SET }
  | "TO"          { TO }
  | "ADD"         { ADD }
  | "SUBTRACT"    { SUBTRACT }
  | "FROM"        { FROM }
  | "PARALLEL"    { PARALLEL }
  | "ENDPARALLEL" { ENDPARALLEL }
  | "FETCH"       { FETCH }
  | "INTO"        { INTO }
  | "TRY"         { TRY }
  | "CATCH"       { CATCH }
  | "ENDTRY"      { ENDTRY }
  | "WRITE"       { WRITE }
  | "FILE"        { FILE }
  | "READ"        { READ }
  | "STOP"        { STOP }
  | "TIMES"       { TIMES }
  | number as n   { NUMBER (int_of_string n) }
  | whitespace    { token lexbuf }
  | "START"       { START }
  | "END"         { END }
  | "TASK"        { TASK }
  | "IF"          { IF }
  | "ELSE"        { ELSE }
  | "ENDIF"       { ENDIF }
  | "CONDITION"   { CONDITION }
  | "NOTIFY"      { NOTIFY }
  | "LOG"         { LOG }
  | "ALERT"       { ALERT }
  | var_interp as v { STRING v }  (* Treat variable interpolation as a string *)
  | string as s   { STRING (String.sub s 1 (String.length s - 2)) }
  | eof           { EOF }
  | _             { raise (Lexing_error ("Unknown token: " ^ Lexing.lexeme lexbuf)) } 