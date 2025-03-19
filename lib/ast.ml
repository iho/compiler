type task =
  | Notify of string
  | Log of string
  | Alert of string
  | Fetch of string * string  (* URL, variable *)
  | Write of string * string  (* content, filename *)
  | Read of string * string   (* filename, variable *)

type expr =
  | Task of task
  | If of string * expr list * expr list
  | Repeat of int * expr list          (* times, body *)
  | While of string * expr list        (* condition, body *)
  | Wait of int                        (* seconds *)
  | Set of string * int                (* var, value *)
  | Add of int * string                (* value, var *)
  | Subtract of int * string           (* value, var *)
  | Parallel of expr list
  | Try of expr list * expr list       (* try block, catch block *)
  | Stop

type program = expr list