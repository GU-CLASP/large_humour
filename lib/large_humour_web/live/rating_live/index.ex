defmodule LargeHumourWeb.RatingLive.Index do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Ratings

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Ratings
        <:actions>
          <.button variant="primary" navigate={~p"/ratings/new"}>
            <.icon name="hero-plus" /> New Rating
          </.button>
        </:actions>
      </.header>

      <.table
        id="ratings"
        rows={@streams.ratings}
        row_click={fn {_id, rating} -> JS.navigate(~p"/ratings/#{rating}") end}
      >
        <:col :let={{_id, rating}} label="Joke">{rating.joke_id}</:col>
        <:col :let={{_id, rating}} label="Rating">{rating.rating}</:col>
        <:action :let={{_id, rating}}>
          <div class="sr-only">
            <.link navigate={~p"/ratings/#{rating}"}>Show</.link>
          </div>
          <.link navigate={~p"/ratings/#{rating}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, rating}}>
          <.link
            phx-click={JS.push("delete", value: %{id: rating.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Ratings")
     |> stream(:ratings, list_ratings())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    rating = Ratings.get_rating!(id)
    {:ok, _} = Ratings.delete_rating(rating)

    {:noreply, stream_delete(socket, :ratings, rating)}
  end

  defp list_ratings() do
    Ratings.list_ratings()
  end
end
