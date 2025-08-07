defmodule SayLess.ExternalApis.OpenLibrary do
  @moduledoc """
  Client for fetching book data from the OpenLibrary API.
  """
  @behaviour SayLess.ExternalApis.Client

  @base_url "https://openlibrary.org/works"

  @impl SayLess.ExternalApis.Client
  def fetch_content(params) do
    media_id = Map.get(params, "media_id")

    if media_id do
      url = "#{@base_url}/#{media_id}.json"
      make_request(url)
    else
      {:error, "Missing 'media_id' for OpenLibrary."}
    end
  end

  defp make_request(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_response(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Book not found on OpenLibrary."}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to connect to OpenLibrary: #{reason}"}
    end
  end

  defp parse_response(body) do
    with {:ok, json} <- Jason.decode(body) do
      # We extract the book's description. In a real app, this would be the chapter text.
      description =
        case Map.get(json, "description") do
          %{"value" => text} -> text
          string when is_binary(string) -> string
          _ -> "No description available for this work."
        end

      {:ok, description}
    else
      _ -> {:error, "Failed to parse OpenLibrary response."}
    end
  end
end
