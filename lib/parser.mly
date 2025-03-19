%{
open Ast
%}


%token REPEAT ENDREPEAT WHILE ENDWHILE WAIT SECONDS SET TO ADD SUBTRACT FROM
%token ALERT LOG NOTIFY IF ELSE ENDIF CONDITION END EOF START TASK
%token PARALLEL ENDPARALLEL FETCH INTO TRY CATCH ENDTRY WRITE FILE READ STOP TIMES
%token<int> NUMBER
%token<string> STRING

%start<Ast.program> program

%%

program:
  | START expr_list END EOF { $2 }

expr_list:
  | { [] }
  | expr expr_list { $1 :: $2 }

expr:
  | TASK task              { Task $2 }
  | IF CONDITION STRING expr_list ELSE expr_list ENDIF { If ($3, $4, $6) }
  | REPEAT NUMBER TIMES expr_list ENDREPEAT { Repeat ($2, $4) }
  | WHILE CONDITION STRING expr_list ENDWHILE { While ($3, $4) }
  | WAIT NUMBER SECONDS    { Wait $2 }
  | SET STRING TO NUMBER   { Set ($2, $4) }
  | ADD NUMBER TO STRING   { Add ($2, $4) }
  | SUBTRACT NUMBER FROM STRING { Subtract ($2, $4) }
  | PARALLEL expr_list ENDPARALLEL { Parallel $2 }
  | TRY expr_list CATCH expr_list ENDTRY { Try ($2, $4) }
  | STOP                   { Stop }

task:
  | NOTIFY STRING { Notify $2 }
  | LOG STRING    { Log $2 }
  | ALERT STRING  { Alert $2 }
  | FETCH STRING INTO STRING { Fetch ($2, $4) }
  | WRITE STRING TO FILE STRING { Write ($2, $5) }
  | READ FILE STRING INTO STRING { Read ($3, $5) }
