defmodule SayLess do
  @moduledoc """
  The main context for the SayLess application.
  It orchestrates fetching media content and generating summaries.
  """

  alias SayLess.ExternalApis
  alias SayLess.Ai.Summarizer

  @doc """
  The main function to generate a summary.

  It takes parameters from the controller, fetches the relevant content
  from the specified external API, and then calls the AI summarizer.
  """
  def generate_summary(params) do
    with {:ok, content_to_summarize} <- ExternalApis.fetch_content(params) do
      Summarizer.generate_summary_from_content(content_to_summarize, params)
    end
  end
end
