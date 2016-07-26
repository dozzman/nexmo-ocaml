open Lwt
open Cohttp
open Cohttp_lwt_unix

exception Parse_exception of string

type sms_request = {
  credentials: Credentials.t;
  from: string;
  dest: string;
  msg: string
}

type sms_success_response = {
  message_id : string;
  recipent : string;
  remaining_balance: float;
  message_price: float;
  network: string
}

type message_status =
| Success of sms_success_response list
| Throttled of string
| Missing_Params of string
| Invalid_Params of string
| Invalid_Credentials of string
| Internal_Error of string
| Invalid_Message of string
| Number_Barred of string
| Partner_Account_Barred of string
| Partner_Quota_Exceeded of string
| Too_Many_Existing_Binds of string
| Account_Not_Enabled_for_Http of string
| Message_Too_Long of string
| Comms_Failure of string
| Invalid_Signature of string
| Invalid_Sender_Address of string
| Invalid_TTL of string
| Number_Unreachable of string
| Too_Many_Destinations of string
| Facility_Not_Allowed of string
| Invalid_Message_Class of string

let path = "/sms/json"

let param_to = "to"
let param_from = "from"
let param_text = "text"

let uri_of_sms_request sms_request =
  let params = [(param_to, sms_request.dest);
                (param_from, sms_request.from);
                (param_text, sms_request.msg)] in
    Api.make_uri path sms_request.credentials params


let parse_success_message msg =
  let open Yojson.Basic.Util in
  let message_id = msg |> member "message-id" |> to_string in
  let recipent = msg |> member "to" |> to_string in
  let remaining_balance = msg |> member "remaining-balance" |> to_string |> float_of_string in
  let message_price = msg |> member "message-price" |> to_string |> float_of_string in
  let network = msg |> member "network" |> to_string in
    { message_id = message_id;
      recipent = recipent;
      remaining_balance = remaining_balance;
      message_price = message_price;
      network = network }


let parse_error_message msg =
  let open Yojson.Basic.Util in
    msg |> member "error-text" |> to_string


let parse_message msg =
  let open Yojson.Basic.Util in
  let status = msg |> member "status" |> to_string |> int_of_string in
    match status with
    | 0 -> Success [parse_success_message msg]
    | _ -> Internal_Error (parse_error_message msg)


let message_status_from_json json =
  let open Yojson.Basic.Util in
  try
    let message_count = json |> member "message-count" |> to_string |> int_of_string in
      if message_count <= 0 then raise (Parse_exception "No information on messages returned");
      let message = json |> member "messages" |> index 0 in
        parse_message message
  with
  | Parse_exception e ->
    Internal_Error e
  | _ ->
    Internal_Error ("Failed to parse JSON: " ^ (Yojson.Basic.Util.to_string json))


let send_request sms_request = 
  let uri = uri_of_sms_request sms_request in
    Client.get uri >>= fun (resp, body) ->
      body |> Cohttp_lwt_body.to_string >|=
      Yojson.Basic.from_string >|=
      message_status_from_json


let send ~credentials ~from ~dest ~msg =
  let sms_request = {
    credentials = credentials;
    from = from;
    dest = dest;
    msg = msg
  } in
    send_request sms_request
