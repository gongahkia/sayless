defmodule SayLessWeb.V1.SummaryView do
  # The "use Phoenix.View" line has been removed.

  @doc """
  Renders the successful summary response in the required JSON format.
  """
  def render("summary.json", %{summary: summary}) do
    %{
      data: %{
        summary: summary
      }
    }
  end
end
