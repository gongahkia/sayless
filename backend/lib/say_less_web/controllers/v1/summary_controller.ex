defmodule SayLessWeb.V1.SummaryController do
  use Phoenix.Controller, format: "json", layout: false

  alias SayLess

  # If any function clause in `create/2` fails to match (e.g., an error tuple is returned),
  # Phoenix will invoke the `call/2` function in `SayLessWeb.V1.ErrorView`.
  action_fallback SayLessWeb.V1.ErrorView

  @doc """
  Handles the creation of a new summary.
  It takes the request parameters, passes them to the core SayLess context,
  and renders a success or error response.
  """
  def create(conn, params) do
    # The `with` statement provides robust error handling. If `SayLess.generate_summary`
    # returns {:error, _}, the `with` block will halt and the controller will fall back
    # to the ErrorView to render a standardized error.
    with {:ok, summary} <- SayLess.generate_summary(params) do
      conn
      |> put_status(:created) # Sets the HTTP status to 201 Created
      |> render("summary.json", summary: summary)
    end
  end
end
