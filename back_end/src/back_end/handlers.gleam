import envoy
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/result
import gleam/string
import simplifile
import wisp.{type Request, type Response}

pub fn serve_index(static_dir: String) -> Response {
  let index_html_path = static_dir <> "/index.html"
  case simplifile.read(index_html_path) {
    Ok(html) ->
      wisp.ok()
      |> wisp.html_body(html)
    Error(err) -> {
      wisp.log_error("Failed to read index.html: " <> string.inspect(err))
      wisp.internal_server_error()
    }
  }
}

pub fn health_check() -> Response {
  wisp.ok()
}

pub fn simulate(req: Request) -> Response {
  use body <- wisp.require_string_body(req)

  let julia_url =
    envoy.get("JULIA_URL")
    |> result.unwrap("http://localhost:8080")

  wisp.log_info(
    "Forwarding to Julia at: " <> julia_url <> ". Request body: " <> body,
  )

  let result = {
    use julia_req <- result.try(
      request.to(julia_url)
      |> result.replace_error(Nil),
    )
    let julia_req =
      julia_req
      |> request.set_method(http.Post)
      |> request.set_body(body)
      |> request.set_header("content-type", "application/json")

    httpc.send(julia_req)
    |> result.replace_error(Nil)
  }

  case result {
    Ok(resp) -> {
      wisp.log_info("Julia response status: " <> string.inspect(resp.status))
      wisp.response(resp.status)
      |> wisp.set_header("content-type", "image/svg+xml")
      |> wisp.string_body(resp.body)
    }
    Error(_) -> {
      wisp.log_error("Failed to reach Julia")
      wisp.internal_server_error()
    }
  }
}
