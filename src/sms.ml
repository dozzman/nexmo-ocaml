open Lwt
open Cohttp
open Cohttp_lwt_unix

type sms_request = {
  credentials: Credentials.t;
  src: string;
  dest: string;
  body: string
}

let path = "/sms/json"

let param_to = "to"
let param_from = "from"
let param_text = "text"

let uri_of_sms_request sms_request =
  let params = [(param_to, sms_request.dest);
                (param_from, sms_request.src);
                (param_text, sms_request.body)] in
    Api.make_uri path sms_request.credentials params

let send_request sms_request = 
  let uri = uri_of_sms_request sms_request in
    Client.get uri >>= fun (resp, body) ->
      print_endline "sms sent!";
      Lwt.return ()

let send credentials src dest body = 
  let sms_request = {
    credentials = credentials;
    src = src;
    dest = dest;
    body = body
  } in
    send_request sms_request
