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

val send : credentials:Credentials.t -> from:string -> dest:string -> msg:string -> message_status Lwt.t

val send_request : sms_request -> message_status Lwt.t

