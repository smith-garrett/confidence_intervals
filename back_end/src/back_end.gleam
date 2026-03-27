import back_end/router
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(priv_dir) = wisp.priv_directory("back_end")
  let static_dir = priv_dir <> "/static"

  let assert Ok(_) =
    router.handle_request(static_dir, _)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start

  process.sleep_forever()
}
