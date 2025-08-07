defmodule SayLess.Ai.Summarizer do
  @moduledoc """
  Handles all interactions with the Google Gemini AI model for summarization.
  """
  alias SayLess.Schemas.SummarySchema

  @gemini_api_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"

  def generate_summary_from_content(content, params) do
    api_key = Application.fetch_env!(:say_less, :gemini_api_key)
    headers = [{"Content-Type", "application/json"}]
    body = build_request_body(content, params)

    url = "#{@gemini_api_url}?key=#{api_key}"

    with {:ok, response} <- HTTPoison.post(url, body, headers),
         {:ok, parsed_body} <- Jason.decode(response.body) do
      parse_gemini_response(parsed_body)
    else
      {:ok, %{status_code: code, body: body}} ->
        {:error, "AI service returned an error (Status #{code}): #{body}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to communicate with AI service: #{reason}"}
    end
  end

  defp build_request_body(content, params) do
    prompt = create_prompt(content, params["target_name"], params["media_title"])

    # This map now uses idiomatic Elixir atom keys.
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
      ]
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

  defp parse_gemini_response(parsed_body) do
    case get_in(parsed_body, ["candidates", 0, "content", "parts", 0, "functionCall", "args"]) do
      nil ->
        error_text = get_in(parsed_body, ["candidates", 0, "finishReason"])
        {:error, "AI model failed to generate a valid summary. Reason: #{error_text}"}
      args_map ->
        {:ok, args_map}
    end
  end
end
