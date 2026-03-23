defmodule LargeHumourWeb.Router do
  use LargeHumourWeb, :router

  import LargeHumourWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LargeHumourWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
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

  scope "/", LargeHumourWeb do
    pipe_through [:browser]

    live "/ratings/new", RatingLive.Form, :new
  end

  ## Authentication routes

  scope "/", LargeHumourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LargeHumourWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      live "/", GenerateLive
      live "/gen", GenerateLive

      live "/jokes", JokeLive.Index, :index
      live "/jokes/new", JokeLive.Form, :new
      live "/jokes/:id", JokeLive.Show, :show
      live "/jokes/:id/edit", JokeLive.Form, :edit

      live "/prompts", PromptLive.Index, :index
      live "/prompts/new", PromptLive.Form, :new
      live "/prompts/:id", PromptLive.Show, :show
      live "/prompts/:id/edit", PromptLive.Form, :edit

      live "/ratings", RatingLive.Index, :index
      live "/ratings/:id", RatingLive.Show, :show
      live "/ratings/:id/edit", RatingLive.Form, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", LargeHumourWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{LargeHumourWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
