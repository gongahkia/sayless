defmodule SayLessWeb.V1.SummaryView do
  use SayLessWeb, :view

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
