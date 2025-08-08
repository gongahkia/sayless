defmodule SayLess.Ai.Summarizer do
  @moduledoc """
  Handles all interactions with the Google Gemini AI model for summarization.
  """
  alias SayLess.Schemas.SummarySchema

  @gemini_api_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  def generate_summary_from_content(content, params) do
    api_key = Application.fetch_env!(:say_less, :gemini_api_key)

    # Using the X-goog-api-key header, which is the modern standard.
    headers = [
      {"Content-Type", "application/json"},
      {"X-goog-api-key", api_key}
    ]
    body = build_request_body(content, params)

    # The API key is now in the header, not the URL.
    with {:ok, %{status_code: 200, body: resp_body}} <- HTTPoison.post(@gemini_api_url, body, headers),
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

  # --- THIS IS THE FINAL, CORRECTED PARSER ---
  defp parse_gemini_response(parsed_body) do
    # The Gemini API returns a list of candidates. We will robustly handle this.
    candidates = get_in(parsed_body, ["candidates"])

    case candidates do
      # Case 1: The candidates list exists and has at least one candidate.
      # We use pattern matching on `[head | _]` to safely get the first element.
      [head | _] ->
        finish_reason = get_in(head, ["finishReason"])

        cond do
          # First, check if the model stopped for a reason other than "STOP".
          # This is often due to safety filters.
          finish_reason not in ["STOP", nil] ->
            {:error, "AI model stopped for reason: '#{finish_reason}'. The prompt may have been blocked."}

          # Next, safely get the list of "parts" from the content.
          parts = get_in(head, ["content", "parts"]) ->
            case parts do
              # The parts list has at least one part. Get the head.
              [first_part | _] ->
                # Now check this first part for the function call we expect.
                if function_args = get_in(first_part, ["functionCall", "args"]) do
                  {:ok, function_args}
                else
                  {:error, "AI returned a response part, but it was not the expected function call."}
                end
              # The parts list was empty.
              _ ->
                {:error, "AI response contained an empty 'parts' list."}
            end

          # If the "content" or "parts" keys were missing.
          true ->
            {:error, "AI returned an unparsable response structure. Candidate Body: #{inspect(head)}"}
        end

      # Case 2: The candidates list is empty or doesn't exist.
      _ ->
        {:error, "AI model returned no candidates in the response. Full Body: #{inspect(parsed_body)}"}
    end
  end
end
