defmodule SayLess.Schemas.SummarySchema do
  @moduledoc """
  Defines the required JSON schema for the AI-generated summary.
  This structure is passed to the Gemini API to enforce a consistent output format.
  """

  @doc """
  Returns the schema definition as an Elixir map.
  """
  def get_schema_definition do
    %{
      type: :object,
      properties: %{
        characters: %{
          type: :array,
          items: %{type: :string},
          description: "A list of key characters who appear or are mentioned in this section."
        },
        plot_points: %{
          type: :array,
          items: %{type: :string},
          description: "A sequential list of the main events and plot developments."
        },
        key_events: %{
          type: :string,
          description: "A concise, one-sentence summary of the most critical event or outcome from this section."
        }
      },
      required: ["characters", "plot_points", "key_events"]
    }
  end
end