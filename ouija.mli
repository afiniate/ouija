type ('handler) t with sexp_of

type params = (string * string) list

val init: char -> 'handler t
val resolve_path: 'handler t -> string -> (params * 'handler) list
val insert_handler: 'handler t -> string -> 'handler -> 'handler t
