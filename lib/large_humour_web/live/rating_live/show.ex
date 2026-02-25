defmodule LargeHumourWeb.RatingLive.Show do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Ratings

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Rating {@rating.id}
        <:subtitle>This is a rating record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/ratings"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/ratings/#{@rating}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit rating
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Joke">{@rating.joke_id}</:item>
        <:item title="Rating">{@rating.rating}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Rating")
     |> assign(:rating, Ratings.get_rating!(id))}
  end
end
