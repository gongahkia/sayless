defmodule SayLess.Ai.Summarizer do
  @moduledoc """
  Handles all interactions with the Google Gemini AI model for summarization.
  """
  alias SayLess.Schemas.SummarySchema

  # Using the Gemini 2.0 URL as previously requested.
  @gemini_api_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  def generate_summary_from_content(content, params) do
    api_key = Application.fetch_env!(:say_less, :gemini_api_key)
    headers = [{"Content-Type", "application/json"}]
    body = build_request_body(content, params)

    url = "#{@gemini_api_url}?key=#{api_key}"

    # This 'with' block includes better error handling for non-200 responses.
    with {:ok, %{status_code: 200, body: resp_body}} <- HTTPoison.post(url, body, headers),
         {:ok, parsed_body} <- Jason.decode(resp_body) do
      parse_gemini_response(parsed_body)
    else
      {:ok, %{status_code: code, body: error_body}} ->
        {:error, "AI service returned a non-200 status. Code: #{code}, Body: #{inspect(error_body)}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to connect to AI service. Reason: #{reason}"}
    end
  end

  defp build_request_body(content, params) do
    prompt = create_prompt(content, params["target_name"], params["media_title"])
    Jason.encode!(%{
      contents: [%{parts: [%{text: prompt}]}],
      generationConfig: %{response_mime_type: "application/json"},
      tools: [%{function_declarations: [%{name: "summarize_section", description: "Creates a structured summary of a piece of content.", parameters: SummarySchema.get_schema_definition()}]}]
    })
  end

  defp create_prompt(content, target, title) do
    """
    You are an expert summarizer for the 'SayLess' app. Your task is to provide a concise summary of a specific section of a media work, based on the content provided.
    The user wants to skip reading or watching the section named '#{target}' of the work '#{title}'.

    Based *only* on the text content below, please extract the key information.
    --- CONTENT TO SUMMARIZE ---
    #{content}
    --------------------------
    Now, call the `summarize_section` function with the extracted information.
    """
  end

  # --- THIS IS THE NEW, MORE ROBUST PARSER ---
  defp parse_gemini_response(parsed_body) do
    case get_in(parsed_body, ["candidates", 0]) do
      # Case 1: The model returned no candidates.
      nil ->
        {:error, "AI model returned an empty or invalid response. Full Body: #{inspect(parsed_body)}"}

      # Case 2: A candidate was returned.
      candidate ->
        finish_reason = get_in(candidate, ["finishReason"])

        cond do
          # Check for safety blocks or other non-standard stops first.
          finish_reason not in ["STOP", nil] ->
            {:error, "AI model stopped for reason: '#{finish_reason}'. The prompt may have been blocked by safety filters."}

          # Try to get the function call we expect.
          function_args = get_in(candidate, ["content", "parts", 0, "functionCall", "args"]) ->
            {:ok, function_args}

          # If there's no function call, check for a direct text response.
          text_response = get_in(candidate, ["content", "parts", 0, "text"]) ->
            {:error, "AI returned a direct text response instead of a summary: '#{text_response}'"}

          # If all else fails, the structure is unknown.
          true ->
            {:error, "AI returned an unparsable response structure. Candidate Body: #{inspect(candidate)}"}
        end
    end
  end
end
