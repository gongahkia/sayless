defmodule SayLessWeb.V1.ErrorView do
  import Plug.Conn
  import Phoenix.Controller, only: [put_view: 2, render: 3]

  def init(opts), do: opts

  # This is the entry point from the controller's `action_fallback`.
  def call(conn, {:error, reason}) when is_binary(reason) do
    conn
    |> put_status(:bad_request)
    |> put_view(SayLessWeb.V1.ErrorView)
    |> render("error.json", reason: reason)
  end

  # This render function is called by `call/2` above.
  def render("error.json", %{reason: reason}) do
    %{errors: %{detail: reason}}
  end
end
