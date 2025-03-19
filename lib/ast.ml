type task =
  | Notify of string
  | Log of string
  | Alert of string

type expr =
  | Task of task
  | If of string * expr list * expr list

type program = expr list 