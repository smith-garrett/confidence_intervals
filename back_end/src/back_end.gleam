import back_end/router
import envoy
import gleam/erlang/process
import gleam/int
import mist
import wisp
import wisp/wisp_mist

fn get_host() -> String {
  case envoy.get("HOST") {
    Ok(host) -> host
    Error(_) -> "localhost"
    // Default if HOST is not set
  }
}

fn get_port() -> Int {
  case envoy.get("PORT") {
    Ok(port) -> {
      case int.parse(port) {
        Ok(port_number) -> port_number
        Error(_) -> 8080
        // Default if PORT cannot be parsed as an int
      }
    }
    Error(_) -> 3000
    // Default if PORT is not set (e.g. during `gleam run`)
  }
}

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(priv_dir) = wisp.priv_directory("back_end")
  let static_dir = priv_dir <> "/static"

  let assert Ok(_) =
    router.handle_request(static_dir, _)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.bind(get_host())
    |> mist.port(get_port())
    |> mist.start

  process.sleep_forever()
}
