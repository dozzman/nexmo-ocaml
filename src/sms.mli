type sms_request

val send : Credentials.t -> string -> string -> string -> unit Lwt.t

val send_request : sms_request -> unit Lwt.t

