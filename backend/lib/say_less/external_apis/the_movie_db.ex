defmodule SayLess.ExternalApis.TheMovieDb do
  @moduledoc """
  Client for fetching movie data from The Movie Database (TMDb).
  """
  @behaviour SayLess.ExternalApis.Client

  @base_url "https://api.themoviedb.org/3"

  @impl SayLess.ExternalApis.Client
  def fetch_content(params) do
    # For TMDb, we expect a `media_id` which is the movie's ID.
    with {:ok, media_id} <- {:ok, Map.get(params, "media_id")} do
      api_key = Application.fetch_env!(:say_less, :tmdb_api_key)
      url = "#{@base_url}/movie/#{media_id}?api_key=#{api_key}"
      make_request(url)
    else
      nil -> {:error, "Missing 'media_id' for TheMovieDb."}
    end
  end

  defp make_request(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_response(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Movie not found on TMDb."}
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        {:error, "Invalid API Key for TMDb. Please check your .env file."}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to connect to TMDb API: #{reason}"}
    end
  end

  defp parse_response(body) do
    with {:ok, json} <- Jason.decode(body) do
      # We extract the movie's "overview" to use as the summary content.
      overview = Map.get(json, "overview") || "No overview available for this movie."
      {:ok, overview}
    else
      _ -> {:error, "Failed to parse TMDb API response."}
    end
  end
end
