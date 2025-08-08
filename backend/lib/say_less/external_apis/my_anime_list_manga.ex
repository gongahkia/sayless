defmodule SayLess.ExternalApis.MyAnimeListManga do
  @moduledoc """
  Client for fetching manga data from MyAnimeList via the Jikan API.
  This module fetches the main synopsis for a given manga series.
  """
  @behaviour SayLess.ExternalApis.Client

  @base_url "https://api.jikan.moe/v4"

  @impl SayLess.ExternalApis.Client
  def fetch_content(params) do
    # For manga, we only need the media_id to get the main synopsis.
    with {:ok, media_id} <- {:ok, Map.get(params, "media_id")} do
      url = "#{@base_url}/manga/#{media_id}"
      make_request(url)
    else
      nil -> {:error, "Missing 'media_id' for MyAnimeListManga."}
    end
  end

  defp make_request(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_response(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Manga not found on MyAnimeList/Jikan."}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to connect to Jikan API: #{reason}"}
    end
  end

  defp parse_response(body) do
    with {:ok, json} <- Jason.decode(body) do
      # Jikan nests the manga data under a "data" key.
      synopsis = get_in(json, ["data", "synopsis"]) || "No synopsis available for this manga."
      {:ok, synopsis}
    else
      _ -> {:error, "Failed to parse Jikan API response."}
    end
  end
end
