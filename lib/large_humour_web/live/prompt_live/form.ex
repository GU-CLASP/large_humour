defmodule LargeHumourWeb.PromptLive.Form do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Prompts
  alias LargeHumour.Prompts.Prompt

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage prompt records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="prompt-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:body]} type="textarea" class="w-full textarea h-64" label="Body" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Prompt</.button>
          <.button navigate={return_path(@return_to, @prompt)}>Cancel</.button>
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
    prompt = Prompts.get_prompt!(id)

    socket
    |> assign(:page_title, "Edit Prompt")
    |> assign(:prompt, prompt)
    |> assign(:form, to_form(Prompts.change_prompt(prompt)))
  end

  defp apply_action(socket, :new, _params) do
    prompt = %Prompt{}

    socket
    |> assign(:page_title, "New Prompt")
    |> assign(:prompt, prompt)
    |> assign(:form, to_form(Prompts.change_prompt(prompt)))
  end

  @impl true
  def handle_event("validate", %{"prompt" => prompt_params}, socket) do
    changeset = Prompts.change_prompt(socket.assigns.prompt, prompt_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"prompt" => prompt_params}, socket) do
    save_prompt(socket, socket.assigns.live_action, prompt_params)
  end

  defp save_prompt(socket, :edit, prompt_params) do
    case Prompts.update_prompt(socket.assigns.prompt, prompt_params) do
      {:ok, prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Prompt updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, prompt))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_prompt(socket, :new, prompt_params) do
    case Prompts.create_prompt(prompt_params) do
      {:ok, prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Prompt created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, prompt))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _prompt), do: ~p"/prompts"
  defp return_path("show", prompt), do: ~p"/prompts/#{prompt}"
end
