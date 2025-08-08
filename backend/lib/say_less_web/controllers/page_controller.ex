defmodule SayLessWeb.V1.PageController do
  use Phoenix.Controller, format: "json", layout: false

  def index(conn, _params) do
    json(conn, %{message: "Welcome to the SayLess API!"})
  end
end
