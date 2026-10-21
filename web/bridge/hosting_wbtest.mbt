///|
test "hosting selects the deployed gateway without accepting arbitrary destinations" {
  let pages = web_json(hosting_config(true))
  assert_eq(field(pages, "origin"), "https://william206920.github.io")
  assert_eq(
    field(pages, "api"),
    "https://spliteasy-online.vercel.app/api/parse",
  )
  assert_eq(field(web_json(hosting_config(false)), "api"), "/api/parse")
  assert_eq(web_api_endpoint(field(pages, "api")), field(pages, "api"))
  for
    invalid in [
      "", "/api/parse", "https://evil.invalid/api/parse", "//evil.invalid", "https://spliteasy-online.vercel.app.evil.invalid/api/parse",
    ] {
    assert_eq(web_api_endpoint(invalid), "/api/parse")
  }
}

///|
fn hosting_policy(
  http_method : String,
  origin : String,
  site : String,
  requested~ : String = "",
  headers~ : String = "",
) -> Json raise @shared.BillError {
  web_json(
    gateway_http_policy(
      http_method, origin, "https://spliteasy-online.vercel.app", site, requested,
      headers,
    ),
  )
}

///|
test "Pages requests are allowed while deceptive origin suffixes are rejected" {
  for verb in ["GET", "POST"] {
    let pages = hosting_policy(verb, web_pages_origin, "cross-site")
    assert_true(web_bool(pages, "allowed"))
    assert_eq(field(pages, "cors"), web_pages_origin)
    for
      foreign in [
        "null", "http://william206920.github.io", "https://william206920.github.io.evil.invalid",
        "https://other.github.io", "https://william206920.github.io/split-easy/",
        "https://william206920.github.io:444", "https://evil.invalid",
      ] {
      let denied = hosting_policy(verb, foreign, "cross-site")
      assert_false(web_bool(denied, "allowed"))
      assert_eq(field(denied, "cors"), "")
    }
  }
}

///|
test "same-origin Vercel and direct API clients retain existing behavior" {
  for verb in ["GET", "POST"] {
    for origin in ["", "https://spliteasy-online.vercel.app"] {
      let policy = hosting_policy(verb, origin, "same-origin")
      assert_true(web_bool(policy, "allowed"))
      assert_eq(field(policy, "cors"), "")
      assert_true(web_bool(hosting_policy(verb, origin, ""), "allowed"))
      assert_false(
        web_bool(hosting_policy(verb, origin, "cross-site"), "allowed"),
      )
    }
  }
}

///|
test "preflight allows only the actual methods and headers used by the frontend" {
  for requested in ["GET", "POST"] {
    for
      headers in [
        "", "content-type", "authorization", "Content-Type, Authorization", "authorization,content-type",
      ] {
      let policy = hosting_policy(
        "OPTIONS",
        web_pages_origin,
        "cross-site",
        requested~,
        headers~,
      )
      assert_true(web_bool(policy, "allowed"))
      assert_eq(field(policy, "cors"), web_pages_origin)
    }
  }
  for requested in ["", "DELETE", "PUT", "TRACE", "post"] {
    let denied = hosting_policy(
      "OPTIONS",
      web_pages_origin,
      "cross-site",
      requested~,
    )
    assert_false(web_bool(denied, "allowed"))
    assert_eq(field(denied, "cors"), "")
  }
  for
    headers in [
      "x-api-key", "content-type, x-custom", "authorization-malicious", "cookie",
    ] {
    assert_false(
      web_bool(
        hosting_policy(
          "OPTIONS",
          web_pages_origin,
          "cross-site",
          requested="POST",
          headers~,
        ),
        "allowed",
      ),
    )
  }
  assert_false(
    web_bool(hosting_policy("OPTIONS", "", "", requested="POST"), "allowed"),
  )
}
