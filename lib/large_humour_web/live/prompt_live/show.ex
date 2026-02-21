defmodule LargeHumourWeb.PromptLive.Show do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Prompts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Prompt {@prompt.id}
        <:subtitle>This is a prompt record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/prompts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/prompts/#{@prompt}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit prompt
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@prompt.title}</:item>
        <:item title="Body">{@prompt.body}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Prompt")
     |> assign(:prompt, Prompts.get_prompt!(id))}
  end
end
