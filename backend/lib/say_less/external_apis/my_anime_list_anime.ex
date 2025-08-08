defmodule SayLess.ExternalApis.MyAnimeListAnime do
  @moduledoc """
  Client for fetching anime & manga data from MyAnimeList via the Jikan API.
  """
  @behaviour SayLess.ExternalApis.Client

  @base_url "https://api.jikan.moe/v4"

  # For this example, we'll fetch an episode synopsis.
  # The Jikan API is rich; this could be extended to manga chapters.
  @impl SayLess.ExternalApis.Client
  def fetch_content(params) do
    with media_id <- Map.get(params, "media_id"),
         target_name <- Map.get(params, "target_name"), # e.g., "Episode 1"
         {:ok, episode_number} <- parse_episode_number(target_name) do
      url = "#{@base_url}/anime/#{media_id}/episodes/#{episode_number}"
      make_request(url)
    else
      :error -> {:error, "Invalid target format. Use 'Episode X'."}
      nil -> {:error, "Missing 'media_id' or 'target_name' for MyAnimeList."}
    end
  end

  defp make_request(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_response(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Episode not found on MyAnimeList/Jikan."}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to connect to Jikan API: #{reason}"}
    end
  end

  defp parse_response(body) do
    with {:ok, json} <- Jason.decode(body) do
      # Jikan nests the episode data under a "data" key.
      synopsis = get_in(json, ["data", "synopsis"]) || "No synopsis available for this episode."
      {:ok, synopsis}
    else
      _ -> {:error, "Failed to parse Jikan API response."}
    end
  end

  # A simple helper to extract the number from a string like "Episode 10".
  defp parse_episode_number("Episode " <> number_str) do
    case Integer.parse(number_str) do
      {num, ""} -> {:ok, num}
      _ -> :error
    end
  end

  defp parse_episode_number(_), do: :error
end
