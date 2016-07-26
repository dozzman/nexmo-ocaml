type t = {
  api_key : string;
  api_secret : string
}

let param_api_key = "api_key"
let param_api_secret = "api_secret"

let make ~api_key ~api_secret =
  { api_key = api_key;
    api_secret = api_secret
  }

let to_params creds =
  [(param_api_key, creds.api_key);
   (param_api_secret, creds.api_secret)]
