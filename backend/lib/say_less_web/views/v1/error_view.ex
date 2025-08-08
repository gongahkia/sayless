defmodule SayLessWeb.V1.ErrorView do
  # Add these imports to bring in controller-level functions
  import Plug.Conn
  import Phoenix.Controller, only: [put_view: 2, render: 3]

  # This render function is called by the `call/2` function below.
  def render("error.json", %{reason: reason}) do
    %{errors: %{detail: reason}}
  end

  # You can keep this function for when you add Ecto changesets.
  def render("error.json", %{changeset: changeset}) do
    %{errors: format_changeset_errors(changeset)}
  end

  # This is the entry point from the controller's `action_fallback`.
  # It now has the functions it needs.
  def call(conn, {:error, reason}) when is_binary(reason) do
    conn
    |> put_status(:bad_request)
    |> put_view(SayLessWeb.V1.ErrorView) # <- This is the crucial new line
    |> render("error.json", reason: reason) # This will now work correctly
  end

  # Helper to format Ecto changeset errors.
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
