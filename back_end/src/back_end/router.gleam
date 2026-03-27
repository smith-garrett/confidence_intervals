import back_end/handlers
import gleam/http.{Get, Post}
import wisp.{type Request, type Response}

pub fn handle_request(static_dir: String, req: Request) -> Response {
  wisp.log_info("Static dir: " <> static_dir)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/", from: static_dir)

  case req.method, wisp.path_segments(req) {
    Get, [] -> handlers.serve_index(static_dir)
    Get, ["healthz"] -> handlers.health_check()
    Post, ["simulate"] -> handlers.simulate(req)
    _, _ -> wisp.not_found()
  }
}
