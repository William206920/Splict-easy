///|
// URL parsing is a host capability; acceptance rules stay in MoonBit.
extern "js" fn gateway_url_parts(value : String) -> String =
  #| value => { try { const u=new URL(value); return JSON.stringify({scheme:u.protocol,origin:u.origin,path:u.pathname,host:u.hostname,user:u.username,password:u.password,query:u.search,hash:u.hash}); } catch { return '{}'; } }

///|
fn gateway_env(value : Json, key : String) -> String {
  match value {
    Object(fields) =>
      match fields.get(key) {
        Some(String(s)) => s
        _ => ""
      }
    _ => ""
  }
}

///|
fn gateway_alias(value : Json, key : String, fallback_key : String) -> String {
  let primary = gateway_env(value, key)
  if primary.is_empty() {
    gateway_env(value, fallback_key)
  } else {
    primary
  }
}

///|
fn gateway_limit(value : String, fallback : Int32, maximum : Int32) -> Int32 {
  if value.is_empty() {
    return fallback
  }
  let mut number = 0
  for c in value.iter() {
    if c < '0' || c > '9' {
      return fallback
    }
    if number <= maximum {
      number = number * 10 + c.to_int() - 48
    }
  }
  if number < 1 {
    1
  } else if number > maximum {
    maximum
  } else {
    number
  }
}

///|
fn gateway_url(
  value : String,
  completion : Bool,
) -> (String, String) raise @shared.BillError {
  let parts = web_json(gateway_url_parts(value))
  if field(parts, "scheme") != "https:" ||
    !field(parts, "user").is_empty() ||
    !field(parts, "password").is_empty() ||
    !field(parts, "query").is_empty() ||
    !field(parts, "hash").is_empty() {
    @shared.invalid(
      "服务地址必须是无凭据、无查询参数的 HTTPS 地址",
    )
  }
  let mut path = field(parts, "path")
  while path.has_suffix("/") {
    path = path[:path.length() - 1].to_owned()
  }
  if completion && !path.has_suffix("/chat/completions") {
    path = path + "/chat/completions"
  }
  (field(parts, "origin") + path, field(parts, "host"))
}

///|
fn gateway_configuration(text : String) -> String raise @shared.BillError {
  let env = web_json(text)
  let base = gateway_env(env, "MOONBIT_BASE_URL")
  let key = gateway_env(env, "MOONBIT_API_KEY")
  let model = gateway_env(env, "MOONBIT_MODEL")
  let redis = gateway_alias(env, "UPSTASH_REDIS_REST_URL", "KV_REST_API_URL")
  let token = gateway_alias(
    env, "UPSTASH_REDIS_REST_TOKEN", "KV_REST_API_TOKEN",
  )
  for required in [base, key, model, redis, token] {
    if required.trim().is_empty() {
      @shared.invalid("服务配置不完整")
    }
  }
  if key.contains("\r") || key.contains("\n") {
    @shared.invalid("密钥格式无效")
  }
  let invite = gateway_env(env, "SPLITEASY_ACCESS_MODE") == "invite"
  let code = gateway_env(env, "SPLITEASY_ACCESS_CODE")
  if invite && code.length() < 16 {
    @shared.invalid("邀请码长度不足")
  }
  let endpoint = gateway_url(base, true)
  let quota = gateway_url(redis, false)
  let hourly = gateway_limit(
    gateway_env(env, "SPLITEASY_HOURLY_LIMIT"),
    10,
    100,
  )
  let daily = gateway_limit(
    gateway_env(env, "SPLITEASY_DAILY_LIMIT"),
    100,
    10000,
  )
  "{\"enabled\":true,\"endpoint\":" +
  @shared.quote_json(endpoint.0) +
  ",\"provider\":" +
  @shared.quote_json(endpoint.1) +
  ",\"redis\":" +
  @shared.quote_json(quota.0) +
  ",\"model\":" +
  @shared.quote_json(model) +
  ",\"key\":" +
  @shared.quote_json(key) +
  ",\"redisToken\":" +
  @shared.quote_json(token) +
  ",\"code\":" +
  @shared.quote_json(code) +
  ",\"invite\":" +
  (if invite { "true" } else { "false" }) +
  ",\"hourly\":" +
  hourly.to_string() +
  ",\"daily\":" +
  daily.to_string() +
  "}"
}

///|
// Private server configuration must never be returned directly to visitors.
pub fn gateway_config(text : String) -> String {
  gateway_configuration(text) catch {
    _ => "{\"enabled\":false}"
  }
}

///|
fn gateway_parse_input(text : String) -> String raise @shared.BillError {
  let input = @json.parse(text) catch {
    _ => {
      @shared.invalid("请求无效或内容过长")
      Json::null()
    }
  }
  let content = gateway_env(input, "text")
  if !web_bool(input, "consent") ||
    content.trim().is_empty() ||
    content.length() > 8000 {
    @shared.invalid("请确认外发账单，内容限 1–8000 字符")
  }
  "{\"ok\":true,\"text\":" + @shared.quote_json(content) + "}"
}

///|
pub fn gateway_input(text : String) -> String {
  gateway_parse_input(text) catch {
    error => error_result(error)
  }
}

///|
fn gateway_plan(
  model : String,
  provider : String,
  text : String,
) -> String raise @shared.BillError {
  let request = web_json(
    @ai.request_body(
      { base_url: "https://server.invalid/v1", api_key: "server-only", model, },
      text,
    ),
  )
  match request {
    Object(fields) => {
      fields["max_tokens"] = Json::number(4096.0)
      let kimi = (
          provider == "api.moonshot.cn" || provider == "api.moonshot.ai"
        ) &&
        (model == "kimi-k2.5" || model == "kimi-k2.6")
      if provider == "api.deepseek.com" || kimi {
        fields["response_format"] = Json::object({
          "type": Json::string("json_object"),
        })
        fields["thinking"] = Json::object({ "type": Json::string("disabled") })
      }
      if kimi {
        fields["temperature"] = Json::number(0.6)
      }
      request.stringify()
    }
    _ => {
      @shared.invalid("模型请求格式无效")
      ""
    }
  }
}

///|
pub fn gateway_request(
  model : String,
  provider : String,
  text : String,
) -> String {
  gateway_plan(model, provider, text) catch {
    error => error_result(error)
  }
}

///|
fn gateway_check_completion(text : String) -> String raise @shared.BillError {
  let response = web_json(text)
  match response {
    Object(fields) =>
      match fields.get("choices") {
        Some(Array(choices)) if !choices.is_empty() =>
          match choices[0] {
            Object(first) =>
              match first.get("finish_reason") {
                Some(String(reason)) if !reason.is_empty() && reason != "stop" =>
                  @shared.invalid(
                    "模型输出未完整结束，请缩短账单后重新解析。",
                  )
                _ => ()
              }
            _ => ()
          }
        _ => ()
      }
    _ => ()
  }
  model_response(text)
}

///|
pub fn gateway_response(text : String) -> String {
  gateway_check_completion(text) catch {
    error => error_result(error)
  }
}
