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
    # We no longer use 'tools' since we are asking for a direct JSON response.
    Jason.encode!(%{
      contents: [%{parts: [%{text: prompt}]}],
      generationConfig: %{
        response_mime_type: "application/json"
      }
    })
  end

  defp create_prompt(content, target, title) do
    """
    You are an expert summarizer for the 'SayLess' app. Your task is to provide a concise summary of a specific section of a media work.
    The user wants to skip reading or watching the section named '#{target}' of the work '#{title}'.

    Based *only* on the text content provided below, your final output **MUST** be a single, valid JSON object with the following keys: "characters", "key_events", and "plot_points".
    Do not respond with any text other than the JSON object itself.

    --- CONTENT TO SUMMARIZE ---
    #{content}
    --------------------------
    """
  end

  # --- THIS IS THE FINAL PARSER THAT CORRECTLY HANDLES NESTED LISTS ---
  defp parse_gemini_response(parsed_body) do
    # Safely pattern match to get the first candidate from the "candidates" list.
    case get_in(parsed_body, ["candidates"]) do
      [first_candidate | _] ->
        # From the first candidate, safely pattern match to get the first part from the "parts" list.
        case get_in(first_candidate, ["content", "parts"]) do
          [first_part | _] ->
            # Now, safely get the "text" field, which contains our JSON string.
            json_string = get_in(first_part, ["text"])

            if json_string do
              # The text field exists, now we decode the JSON string it contains.
              case Jason.decode(json_string) do
                {:ok, summary_map} -> {:ok, summary_map}
                {:error, _} -> {:error, "AI returned text that was not valid JSON."}
              end
            else
              {:error, "AI response part did not contain the expected 'text' field."}
            end
          _ ->
            {:error, "AI response contained an empty 'parts' list."}
        end
      _ ->
        {:error, "AI model returned no candidates in the response."}
    end
  end
end
