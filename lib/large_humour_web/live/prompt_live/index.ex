defmodule LargeHumourWeb.PromptLive.Index do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Prompts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Prompts
        <:actions>
          <.button variant="primary" navigate={~p"/prompts/new"}>
            <.icon name="hero-plus" /> New Prompt
          </.button>
        </:actions>
      </.header>

      <.table
        id="prompts"
        rows={@streams.prompts}
        row_click={fn {_id, prompt} -> JS.navigate(~p"/prompts/#{prompt}") end}
      >
        <:col :let={{_id, prompt}} label="Title">{prompt.title}</:col>
        <:col :let={{_id, prompt}} label="Body">{prompt.body}</:col>
        <:action :let={{_id, prompt}}>
          <div class="sr-only">
            <.link navigate={~p"/prompts/#{prompt}"}>Show</.link>
          </div>
          <.link navigate={~p"/prompts/#{prompt}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, prompt}}>
          <.link
            phx-click={JS.push("delete", value: %{id: prompt.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Prompts")
     |> stream(:prompts, list_prompts())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    prompt = Prompts.get_prompt!(id)
    {:ok, _} = Prompts.delete_prompt(prompt)

    {:noreply, stream_delete(socket, :prompts, prompt)}
  end

  defp list_prompts() do
    Prompts.list_prompts()
  end
end
