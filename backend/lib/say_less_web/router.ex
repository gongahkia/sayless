defmodule SayLessWeb.Router do
  use Phoenix.Router
  import Phoenix.Controller

  pipeline :api do
    plug :accepts, ["json"]
  end

  # --- Add this new scope to handle the root URL ---
  # This will handle requests made to http://localhost:4000/
  scope "/", SayLessWeb do
    pipe_through :api

    # This new route directs GET / requests to the PageController's index action.
    get "/", V1.PageController, :index
  end

  # This is your existing scope for your versioned API endpoints
  scope "/api/v1", SayLessWeb do
    pipe_through :api

    # This route will handle POST /api/v1/summarize requests
    post "/summarize", V1.SummaryController, :create
  end
end
