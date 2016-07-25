type t

val make : api_key:string -> api_secret:string -> t

val to_params : t -> (string * string) list
