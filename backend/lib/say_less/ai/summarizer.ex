defmodule SayLess.Ai.Summarizer do
  @moduledoc """
  Handles all interactions with the Google Gemini AI model for summarization.
  """
  alias SayLess.Schemas.SummarySchema

  @gemini_api_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  def generate_summary_from_content(content, params) do
    api_key = Application.fetch_env!(:say_less, :gemini_api_key)
    headers = [
      {"Content-Type", "application/json"},
      {"X-goog-api-key", api_key}
    ]
    body = build_request_body(content, params)

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

  # --- THIS IS THE NEW, MORE FORCEFUL PROMPT ---
  defp create_prompt(content, target, title) do
    """
    You are an expert summarizer for the 'SayLess' app. Your task is to provide a concise summary of a specific section of a media work.
    The user wants to skip reading or watching the section named '#{target}' of the work '#{title}'.

    Based *only* on the text content provided below, extract the key information.

    --- CONTENT TO SUMMARIZE ---
    #{content}
    --------------------------

    Your final output **MUST** be a call to the `summarize_section` function.
    Do not respond with plain text. You must call the function with the extracted information.
    """
  end

  defp parse_gemini_response(parsed_body) do
    candidates = get_in(parsed_body, ["candidates"])

    case candidates do
      [head | _] ->
        finish_reason = get_in(head, ["finishReason"])

        cond do
          finish_reason not in ["STOP", nil] ->
            {:error, "AI model stopped for reason: '#{finish_reason}'. The prompt may have been blocked by safety filters."}

          parts = get_in(head, ["content", "parts"]) ->
            case parts do
              [first_part | _] ->
                if function_args = get_in(first_part, ["functionCall", "args"]) do
                  {:ok, function_args}
                else
                  {:error, "AI returned a response part, but it was not the expected function call."}
                end
              _ ->
                {:error, "AI response contained an empty 'parts' list."}
            end

          true ->
            {:error, "AI returned an unparsable response structure. Candidate Body: #{inspect(head)}"}
        end

      _ ->
        {:error, "AI model returned no candidates in the response. Full Body: #{inspect(parsed_body)}"}
    end
  end
end
