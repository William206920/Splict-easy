///|
fn gateway_fixture() -> Map[String, Json] {
  {
    "MOONBIT_BASE_URL": Json::string("https://api.moonshot.cn/v1"),
    "MOONBIT_MODEL": Json::string("kimi-k2.6"),
    "MOONBIT_API_KEY": Json::string("fixture-server-key-not-real"),
    "UPSTASH_REDIS_REST_URL": Json::string("https://quota.invalid"),
    "UPSTASH_REDIS_REST_TOKEN": Json::string("fixture-quota-token"),
  }
}

///|
fn gateway_test_config(env : Map[String, Json]) -> Json raise @shared.BillError {
  web_json(gateway_config(Json::object(env).stringify()))
}

///|
test "gateway rejects missing or wrong-type credentials without leaking values" {
  for
    key in [
      "MOONBIT_BASE_URL", "MOONBIT_MODEL", "MOONBIT_API_KEY", "UPSTASH_REDIS_REST_URL",
      "UPSTASH_REDIS_REST_TOKEN",
    ] {
    for
      invalid in [
        Json::string(""),
        Json::string(" \t"),
        Json::number(1.0),
        Json::null(),
      ] {
      let env = gateway_fixture()
      env[key] = invalid
      let result = gateway_config(Json::object(env).stringify())
      assert_eq(result, "{\"enabled\":false}")
      assert_false(result.contains("fixture"))
    }
  }
  let env = gateway_fixture()
  env["MOONBIT_API_KEY"] = Json::string("fixture\r\nInjected: header")
  assert_false(web_bool(gateway_test_config(env), "enabled"))
}

///|
test "gateway rejects unsafe endpoint and quota URL components" {
  for key in ["MOONBIT_BASE_URL", "UPSTASH_REDIS_REST_URL"] {
    for
      url in [
        "http://insecure.invalid", "https://name:password@server.invalid", "https://server.invalid/?key=value",
        "https://server.invalid/#secret", "not-a-url", "javascript:alert(1)",
      ] {
      let env = gateway_fixture()
      env[key] = Json::string(url)
      assert_false(web_bool(gateway_test_config(env), "enabled"))
    }
  }
}

///|
test "gateway constructs canonical completion paths without double suffixes" {
  for
    base in [
      "https://api.moonshot.cn/v1", "https://api.moonshot.cn/v1/", "https://api.moonshot.cn/v1/chat/completions",
      "https://api.moonshot.cn/v1/chat/completions///",
    ] {
    let env = gateway_fixture()
    env["MOONBIT_BASE_URL"] = Json::string(base)
    let config = gateway_test_config(env)
    assert_true(web_bool(config, "enabled"))
    assert_eq(
      field(config, "endpoint"),
      "https://api.moonshot.cn/v1/chat/completions",
    )
    assert_eq(field(config, "provider"), "api.moonshot.cn")
  }
  let root = gateway_fixture()
  root["MOONBIT_BASE_URL"] = Json::string("https://api.deepseek.com/")
  assert_eq(
    field(gateway_test_config(root), "endpoint"),
    "https://api.deepseek.com/chat/completions",
  )
}

///|
test "gateway invitation mode fails closed and public mode remains explicit" {
  let env = gateway_fixture()
  env["SPLITEASY_ACCESS_MODE"] = Json::string("invite")
  assert_false(web_bool(gateway_test_config(env), "enabled"))
  env["SPLITEASY_ACCESS_CODE"] = Json::string("123456789012345")
  assert_false(web_bool(gateway_test_config(env), "enabled"))
  env["SPLITEASY_ACCESS_CODE"] = Json::string("1234567890123456")
  assert_true(web_bool(gateway_test_config(env), "invite"))
  env["SPLITEASY_ACCESS_MODE"] = Json::string("public")
  assert_false(web_bool(gateway_test_config(env), "invite"))
}

///|
test "gateway limits clamp without integer overflow and reject partial decimals" {
  assert_eq(gateway_limit("", 10, 100), 10)
  assert_eq(gateway_limit("0", 10, 100), 1)
  assert_eq(gateway_limit("00042", 10, 100), 42)
  assert_eq(
    gateway_limit("999999999999999999999999999999999999999999999", 10, 100),
    100,
  )
  assert_eq(
    gateway_limit("99999999999999999999999999999999999999999999x", 10, 100),
    10,
  )
  for invalid in ["-1", "1.5", " 10", "1e2", "+3", "NaN"] {
    assert_eq(gateway_limit(invalid, 10, 100), 10)
  }
  assert_eq(gateway_limit("10001", 100, 10000), 10000)
}

///|
test "gateway KV aliases are accepted while explicit Upstash values take precedence" {
  let env = gateway_fixture()
  env["UPSTASH_REDIS_REST_URL"] = Json::string("")
  env["UPSTASH_REDIS_REST_TOKEN"] = Json::string("")
  env["KV_REST_API_URL"] = Json::string("https://marketplace.invalid/")
  env["KV_REST_API_TOKEN"] = Json::string("marketplace-token")
  let config = gateway_test_config(env)
  assert_true(web_bool(config, "enabled"))
  assert_eq(field(config, "redis"), "https://marketplace.invalid")
  assert_eq(field(config, "redisToken"), "marketplace-token")
  env["UPSTASH_REDIS_REST_URL"] = Json::string("https://explicit.invalid")
  env["UPSTASH_REDIS_REST_TOKEN"] = Json::string("explicit-token")
  let explicit = gateway_test_config(env)
  assert_eq(field(explicit, "redis"), "https://explicit.invalid")
  assert_eq(field(explicit, "redisToken"), "explicit-token")
}

///|
test "gateway validates consent and input types before quota or model work" {
  for
    input in [
      "null", "[]", "broken", "{\"text\":\"账单\"}", "{\"consent\":true,\"text\":123}",
      "{\"consent\":1,\"text\":\"账单\"}", "{\"consent\":true,\"text\":\" \"}",
    ] {
    assert_false(web_bool(web_json(gateway_input(input)), "ok"))
  }
  let text = "引号\"与换行\n账单"
  let valid = web_json(
    gateway_input(
      "{\"consent\":true,\"text\":" + @shared.quote_json(text) + "}",
    ),
  )
  assert_true(web_bool(valid, "ok"))
  assert_eq(field(valid, "text"), text)
}

///|
test "gateway model policies preserve provider-specific structured output" {
  for host in ["api.moonshot.cn", "api.moonshot.ai"] {
    for model in ["kimi-k2.5", "kimi-k2.6"] {
      let body = web_json(gateway_request(model, host, web_free_sample))
      assert_eq(field(body, "model"), model)
      match body {
        Object(fields) => {
          assert_eq(fields.get("temperature"), Some(Json::number(0.6)))
          assert_eq(fields.get("max_tokens"), Some(Json::number(4096.0)))
          match fields.get("thinking") {
            Some(value) => assert_eq(field(value, "type"), "disabled")
            None => fail("thinking mode required")
          }
          match fields.get("response_format") {
            Some(value) => assert_eq(field(value, "type"), "json_object")
            None => fail("JSON mode required")
          }
        }
        _ => fail("request must be an object")
      }
    }
  }
  let generic = web_json(
    gateway_request("other-model", "custom.invalid", web_free_sample),
  )
  match generic {
    Object(fields) => {
      assert_true(fields.get("thinking") is None)
      assert_true(fields.get("temperature") is None)
    }
    _ => fail("request required")
  }
}

///|
test "gateway rejects truncated and ambiguous model responses before preview" {
  let canonical = @shared.encode_ledger(web_fixture())
  let completion = "{\"choices\":[{\"finish_reason\":\"stop\",\"message\":{\"content\":" +
    @shared.quote_json(canonical) +
    "}}]}"
  assert_true(web_bool(web_json(gateway_response(completion)), "ok"))
  for reason in ["length", "content_filter", "tool_calls"] {
    let truncated = completion.replace_all(
      old="\"stop\"",
      new=@shared.quote_json(reason),
    )
    let result = web_json(gateway_response(truncated))
    assert_false(web_bool(result, "ok"))
    assert_true(field(result, "error").contains("未完整结束"))
  }
  assert_false(web_bool(web_json(gateway_response("not-json")), "ok"))
  let ambiguous = "{\"schema_version\":1,\"people\":[\"A\",\"B\"],\"payments\":[],\"ambiguous\":[\"付款人是谁？\"]}"
  let result = web_json(
    gateway_response(
      "{\"choices\":[{\"message\":{\"content\":" +
      @shared.quote_json(ambiguous) +
      "}}]}",
    ),
  )
  assert_false(web_bool(result, "ok"))
  assert_true(field(result, "error").contains("付款人是谁"))
}
