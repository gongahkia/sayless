defmodule SayLess.ExternalApis.Client do
  @moduledoc """
  A behaviour and dispatcher for fetching content from various external APIs.
  """

  @callback fetch_content(params :: map()) :: {:ok, String.t()} | {:error, any()}

  @doc """
  Dynamically dispatches the fetch_content call to the correct client module.
  """
  def fetch_content(params) do
    source = Map.get(params, "source")

    with {:ok, client_module} <- get_client_module(source) do
      client_module.fetch_content(params)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_client_module("openlibrary"), do: {:ok, SayLess.ExternalApis.OpenLibrary}
  defp get_client_module("myanimelist"), do: {:ok, SayLess.ExternalApis.MyAnimeList}
  defp get_client_module(nil), do: {:error, "API source not specified."}
  defp get_client_module(other), do: {:error, "Unsupported API source: #{other}"}
end
