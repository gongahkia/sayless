defmodule SayLessWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :say_less

  # The session will be stored in a cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_say_less_key",
    signing_salt: "YOUR_SECRET_SALT_HERE", # Replace with a long random string
    same_site: "Lax"
  ]

  # Socket handler for Phoenix Channels, if you use them.
  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static assets from "priv/static" directory.
  # It is advisable to move spoils to the end of the pipeline so
  # Plug.Conn can be used before they are served.
  plug Plug.Static,
    at: "/",
    from: :say_less,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug SayLessWeb.Router
end
