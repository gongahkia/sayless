defmodule SayLess.Ai.Summarizer do
  @moduledoc """
  Handles all interactions with the Google Gemini AI model for summarization.
  """

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
    # We no longer need the 'tools' section, as we are asking for a direct JSON response.
    Jason.encode!(%{
      contents: [%{parts: [%{text: prompt}]}],
      generationConfig: %{
        response_mime_type: "application/json"
      }
    })
  end

  # --- THIS PROMPT NOW ASKS FOR A JSON OBJECT, NOT A FUNCTION CALL ---
  defp create_prompt(content, target, title) do
    """
    You are an expert summarizer for the 'SayLess' app. Your task is to provide a concise summary of a specific section of a media work.
    The user wants to skip reading or watching the section named '#{target}' of the work '#{title}'.

    Based *only* on the text content provided below, extract the key information.
    Your final output **MUST** be a single, valid JSON object with the following keys: "characters", "key_events", and "plot_points".
    Do not respond with any text other than the JSON object itself.

    --- CONTENT TO SUMMARIZE ---
    #{content}
    --------------------------
    """
  end

  # --- THIS IS THE FINAL PARSER THAT HANDLES THE STRINGIFIED JSON ---
  defp parse_gemini_response(parsed_body) do
    # Navigate to the text field containing the JSON string.
    json_string = get_in(parsed_body, ["candidates", 0, "content", "parts", 0, "text"])

    case json_string do
      nil ->
        {:error, "AI response did not contain the expected text field."}

      # If we found the string, try to parse it as JSON.
      string when is_binary(string) ->
        with {:ok, summary_map} <- Jason.decode(string) do
          {:ok, summary_map}
        else
          _ -> {:error, "AI returned text that was not valid JSON."}
        end
    end
  end
end
