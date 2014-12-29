type ('a) t

type params = (string * string) list

val init: char -> 'a t
val resolve_path: 'a t -> string -> (params * 'a) list
val insert: 'a t -> string -> 'a -> 'a t
