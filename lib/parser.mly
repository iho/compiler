%{
open Ast
%}

%token START END TASK IF ELSE ENDIF CONDITION NOTIFY LOG ALERT EOF
%token<string> STRING

%start<Ast.program> program

%%

program:
  | START expr_list END EOF { $2 }

expr_list:
  | { [] }
  | expr expr_list { $1 :: $2 }

expr:
  | TASK task { Task $2 }
  | IF CONDITION STRING expr_list ELSE expr_list ENDIF { If ($3, $4, $6) }

task:
  | NOTIFY STRING { Notify $2 }
  | LOG STRING    { Log $2 }
  | ALERT STRING  { Alert $2 } 