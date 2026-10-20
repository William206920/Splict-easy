///|
// Public hosting coordinates; no provider credentials belong in this module.
let web_pages_origin : String = "https://william206920.github.io"

///|
let web_hosted_api : String = "https://spliteasy-online.vercel.app/api/parse"

///|
fn web_api_endpoint(value : String) -> String {
  if value == web_hosted_api {
    web_hosted_api
  } else {
    "/api/parse"
  }
}

///|
pub fn hosting_config(pages : Bool) -> String {
  "{\"api\":" +
  @shared.quote_json(if pages { web_hosted_api } else { "/api/parse" }) +
  ",\"origin\":" +
  @shared.quote_json(web_pages_origin) +
  "}"
}

///|
// Browsers send Origin on CORS requests and OPTIONS before JSON/Authorization.
// Only the owner's Pages origin is trusted; quotas apply to both frontends.
pub fn gateway_http_policy(
  http_method : String,
  origin : String,
  server_origin : String,
  fetch_site : String,
  requested_method : String,
  requested_headers : String,
) -> String {
  let remote = origin == web_pages_origin
  let known = origin.is_empty() || origin == server_origin || remote
  let mut allowed = known && (fetch_site != "cross-site" || remote)
  if http_method == "OPTIONS" {
    allowed = allowed &&
      !origin.is_empty() &&
      (requested_method == "GET" || requested_method == "POST")
    for header in requested_headers.split(",") {
      let name = header.trim().to_owned().to_lower()
      if name != "" && name != "content-type" && name != "authorization" {
        allowed = false
      }
    }
  }
  "{\"allowed\":" +
  (if allowed { "true" } else { "false" }) +
  ",\"cors\":" +
  @shared.quote_json(if allowed && remote { origin } else { "" }) +
  "}"
}
