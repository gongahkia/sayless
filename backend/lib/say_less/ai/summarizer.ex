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

  # --- THIS FUNCTION NOW INCLUDES `tool_config` TO FORCE A FUNCTION CALL ---
  defp build_request_body(content, params) do
    prompt = create_prompt(content, params["target_name"], params["media_title"])

    Jason.encode!(%{
      contents: [%{parts: [%{text: prompt}]}],
      generationConfig: %{
        response_mime_type: "application/json"
      },
      tools: [
        %{
          function_declarations: [
            %{
              name: "summarize_section",
              description: "Creates a structured summary of a piece of content.",
              parameters: SummarySchema.get_schema_definition()
            }
          ]
        }
      ],
      # THIS IS THE CRUCIAL NEW SECTION THAT FORCES THE FUNCTION CALL
      tool_config: %{
        function_calling_config: %{
          mode: "ANY" # This commands the model to use one of the provided functions.
        }
      }
    })
  end

  defp create_prompt(content, target, title) do
    """
    You are an expert summarizer for the 'SayLess' app. Your task is to provide a concise summary of a specific section of a media work.
    The user wants to skip reading or watching the section named '#{target}' of the work '#{title}'.

    Based *only* on the text content provided below, extract the key information and use it to call the summarize_section function.
    """
  end

  # The parser is updated to handle the new `finishReason`
  defp parse_gemini_response(parsed_body) do
    candidates = get_in(parsed_body, ["candidates"])

    case candidates do
      [head | _] ->
        finish_reason = get_in(head, ["finishReason"])

        cond do
          # The model will now stop with "TOOL_USE". We also accept "STOP" and nil for safety.
          finish_reason not in ["STOP", "TOOL_USE", nil] ->
            {:error, "AI model stopped for an unexpected reason: '#{finish_reason}'. The prompt may have been blocked."}

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
