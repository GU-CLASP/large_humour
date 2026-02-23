defmodule LargeHumourWeb.GenerateLive do
  use LargeHumourWeb, :live_view
  alias LargeHumour.Jokes
  alias LargeHumour.Prompts
  alias LargeHumour.LLM

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.form for={@seed} id="gen-form" phx-submit="generate">
        <.input
          field={@seed[:joke_id]}
          name="joke_id"
          type="select"
          label="Joke"
          value="1"
          options={Enum.map(@jokes, &{&1.text, &1.id})}
        />
        <.input
          field={@seed[:prompt_id]}
          name="prompt_id"
          type="select"
          label="Prompt"
          value="1"
          options={Enum.map(@prompts, &{&1.title, &1.id})}
        />
        <.input
          field={@seed[:model_name]}
          name="model_name"
          type="select"
          label="Model"
          value="groq:openai/gpt-oss-120b"
          options={Application.fetch_env!(:large_humour, :req_llms) |> Enum.map(fn x -> {x, x} end)}
        />
        <footer>
          <.button
            phx-disable-with="Generating..."
            variant="primary"
            type="submit"
            disabled={@loading}
          >
            {if @loading, do: "Generating...", else: "Generate!"}
          </.button>
        </footer>
      </.form>

      <.table
        :if={@streams}
        id="new_jokes"
        rows={@streams.new_jokes}
      >
        <:col :let={{_id, joke}}>{joke.text}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event(
        "generate",
        %{"prompt_id" => prompt_id, "joke_id" => joke_id, "model_name" => model},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:loading, true)
     |> start_async(:process_form, fn ->
       LLM.generate_jokes(Jokes.get_joke!(joke_id), %LLM{
         model: model,
         base_prompt: Prompts.get_prompt!(prompt_id).body
       })
     end)}
  end

  @impl true
  def handle_async(:process_form, {:ok, result}, socket) do
    {:noreply,
     socket
     |> assign(:loading, false)
     |> stream(:new_jokes, [], reset: true)
     |> stream(:new_jokes, result)}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Generate Jokes")
     |> assign(:prompts, Prompts.list_prompts())
     |> assign(:seed, %{})
     |> assign(:jokes, list_jokes())
     |> assign(:loading, false)
     |> stream_configure(:new_jokes,
       dom_id: &"joke-#{Ecto.UUID.generate()}-#{&1.source_joke_id}"
     )
     |> stream(:new_jokes, [])}
  end

  defp list_jokes() do
    Jokes.list_jokes() |> Enum.filter(fn j -> j.seed end)
  end
end
