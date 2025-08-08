defmodule SayLessWeb.V1.ErrorView do

  # This is the entry point for the action_fallback in the controller.
  # It receives the connection and the error reason.
  def render("error.json", %{reason: reason}) do
    %{errors: %{detail: reason}}
  end

  # Phoenix may also trigger the fallback with a changeset if you were using Ecto.
  # While not used now, it's good practice to include it.
  def render("error.json", %{changeset: changeset}) do
    %{errors: format_changeset_errors(changeset)}
  end

  # Fallback for the controller's `action_fallback`. This function is invoked
  # when `create/2` in the controller returns an error tuple.
  def call(conn, {:error, reason}) when is_binary(reason) do
    conn
    |> put_status(:bad_request) # Or another appropriate error code
    |> render("error.json", reason: reason)
  end

  # Helper to format Ecto changeset errors into a readable map.
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
