defmodule LargeHumourWeb.Router do
  use LargeHumourWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LargeHumourWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LargeHumourWeb do
    pipe_through :browser

    live "/gen", GenerateLive
    
    live "/jokes", JokeLive.Index, :index
    live "/jokes/new", JokeLive.Form, :new
    live "/jokes/:id", JokeLive.Show, :show
    live "/jokes/:id/edit", JokeLive.Form, :edit

    live "/prompts", PromptLive.Index, :index
    live "/prompts/new", PromptLive.Form, :new
    live "/prompts/:id", PromptLive.Show, :show
    live "/prompts/:id/edit", PromptLive.Form, :edit

    live "/ratings",RatingLive.Index, :index
    live "/ratings/new", RatingLive.Form, :new
    live "/ratings/:id", RatingLive.Show, :show
    live "/ratings/:id/edit", RatingLive.Form, :edit

    
  end

  # Other scopes may use custom stacks.
  # scope "/api", LargeHumourWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:large_humour, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LargeHumourWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
