defmodule LargeHumourWeb.JokeLive.Form do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Jokes
  alias LargeHumour.Jokes.Joke

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage joke records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="joke-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:seed]} type="checkbox" label="Seed" />
        <.input field={@form[:code]} type="text" label="Code" />
        <.input field={@form[:text]} type="textarea" label="Text" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Joke</.button>
          <.button navigate={return_path(@return_to, @joke)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    joke = Jokes.get_joke!(id)

    socket
    |> assign(:page_title, "Edit Joke")
    |> assign(:joke, joke)
    |> assign(:form, to_form(Jokes.change_joke(joke)))
  end

  defp apply_action(socket, :new, _params) do
    joke = %Joke{}

    socket
    |> assign(:page_title, "New Joke")
    |> assign(:joke, joke)
    |> assign(:form, to_form(Jokes.change_joke(joke)))
  end

  @impl true
  def handle_event("validate", %{"joke" => joke_params}, socket) do
    changeset = Jokes.change_joke(socket.assigns.joke, joke_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"joke" => joke_params}, socket) do
    save_joke(socket, socket.assigns.live_action, joke_params)
  end

  defp save_joke(socket, :edit, joke_params) do
    case Jokes.update_joke(socket.assigns.joke, joke_params) do
      {:ok, joke} ->
        {:noreply,
         socket
         |> put_flash(:info, "Joke updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, joke))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_joke(socket, :new, joke_params) do
    case Jokes.create_joke(joke_params) do
      {:ok, joke} ->
        {:noreply,
         socket
         |> put_flash(:info, "Joke created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, joke))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _joke), do: ~p"/jokes"
  defp return_path("show", joke), do: ~p"/jokes/#{joke}"
end
