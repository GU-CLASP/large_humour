defmodule LargeHumourWeb.JokeLive.Index do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Jokes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Jokes
        <:actions>
          <.button variant="primary" navigate={~p"/jokes/new"}>
            <.icon name="hero-plus" /> New Joke
          </.button>
        </:actions>
      </.header>

      <.table
        id="jokes"
        rows={@streams.jokes}
        row_click={fn {_id, joke} -> JS.navigate(~p"/jokes/#{joke}") end}
      >
        <:col :let={{_id, joke}} label="Seed">{joke.seed}</:col>
        <:col :let={{_id, joke}} label="Code">{joke.code}</:col>
        <:col :let={{_id, joke}} label="Text">{joke.text}</:col>
        <:action :let={{_id, joke}}>
          <div class="sr-only">
            <.link navigate={~p"/jokes/#{joke}"}>Show</.link>
          </div>
          <.link navigate={~p"/jokes/#{joke}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, joke}}>
          <.link
            phx-click={JS.push("delete", value: %{id: joke.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Jokes")
     |> stream(:jokes, list_jokes())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    joke = Jokes.get_joke!(id)
    {:ok, _} = Jokes.delete_joke(joke)

    {:noreply, stream_delete(socket, :jokes, joke)}
  end

  defp list_jokes() do
    Jokes.list_jokes()
  end
end
