defmodule LargeHumourWeb.JokeLive.Show do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Jokes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Joke {@joke.id}
        <:subtitle>This is a joke record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/jokes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/jokes/#{@joke}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit joke
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Seed">{@joke.seed}</:item>
        <:item title="Code">{@joke.code}</:item>
        <:item title="Text">{@joke.text}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Joke")
     |> assign(:joke, Jokes.get_joke!(id))}
  end
end
