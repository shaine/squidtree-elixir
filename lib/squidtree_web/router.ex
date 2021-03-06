defmodule SquidtreeWeb.Router do
  use SquidtreeWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "xml"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SquidtreeWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about
    get "sitemap.:format", PageController, :sitemap
    get "sitemap", PageController, :sitemap

    get "/blog", BlogController, :index
    get "/blog/:slug", BlogController, :show
    get "/blog/:year/:month/:day/:slug", BlogController, :show
    get "/notes/:id", NoteController, :show
    get "/notes/:slug/:id", NoteController, :show
    get "/notes", NoteController, :index
    get "/references", ReferenceController, :index
    get "/references/:slug", ReferenceController, :show
    get "/admin/cache_refresh", AdminController, :cache_refresh
  end

  # Other scopes may use custom stacks.
  # scope "/api", SquidtreeWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: SquidtreeWeb.Telemetry
    end
  end
end
