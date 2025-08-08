defmodule SayLess do
  @moduledoc """
  The main context for the SayLess application.
  It orchestrates fetching media content and generating summaries.
  """

  # CHANGE THIS LINE: Alias the correct module, which is .Client
  alias SayLess.ExternalApis.Client
  alias SayLess.Ai.Summarizer

  @doc """
  The main function to generate a summary.

  It takes parameters from the controller, fetches the relevant content
  from the specified external API, and then calls the AI summarizer.
  """
  def generate_summary(params) do
    # AND CHANGE THIS LINE: Call the function on the correct alias (`Client`)
    with {:ok, content_to_summarize} <- Client.fetch_content(params) do
      Summarizer.generate_summary_from_content(content_to_summarize, params)
    end
  end
end
