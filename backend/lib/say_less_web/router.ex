defmodule SayLessWeb.Router do
  use SayLessWeb, :router

  # This pipeline prepares the connection for API requests.
  # It tells Phoenix to only accept requests with the "Accept" header set to "application/json".
  pipeline :api do
    plug :accepts, ["json"]
  end

  # This defines a new scope for our API, prefixing all routes inside with /api/v1.
  # All routes in this scope will pass through the :api pipeline.
  scope "/api/v1", SayLessWeb do
    pipe_through :api

    # Defines the main endpoint for the application.
    # POST /api/v1/summarize -> V1.SummaryController.create/2
    post "/summarize", V1.SummaryController, :create
  end
end
