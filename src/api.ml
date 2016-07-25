let host = "rest.nexmo.com"

let make_uri path creds params =
  let param_creds = Credentials.to_params creds in
  let all_params = param_creds @ params in
  let uri = Uri.make ~scheme:"https"
                     ~host:host
                     ~path:path
                     () in
    Uri.add_query_params' uri all_params
