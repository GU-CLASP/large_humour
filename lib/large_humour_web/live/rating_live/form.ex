defmodule LargeHumourWeb.RatingLive.Form do
  use LargeHumourWeb, :live_view

  alias LargeHumour.Ratings
  alias LargeHumour.Jokes
  alias LargeHumour.Ratings.Rating

  defp rating_schema do
    [
      %{
        digit: 0,
        title: "Not funny at all",
        description: "Text just doesn’t work as a joke and nothing amusing present"
      },
      %{
        digit: 1,
        title: "Barely funny",
        description: "A very weak joke, hardly amusing at all"
      },
      %{
        digit: 2,
        title: "A bit funny",
        description: "The joke may elicit a small amount of amusment"
      },
      %{
        digit: 3,
        title: "Mildly funny",
        description: "Perhaps you smiled, laughed a bit / or thought/said that’s kind of funny"
      },
      %{
        digit: 4,
        title: "Funny",
        description: "You consider this a good joke / you laughed / thought/said “that’s funny”"
      },
      %{
        digit: 5,
        title: "Very funny",
        description: "You laughed deeply / really appreciated the joke"
      },
      %{
        digit: 6,
        title: "Super funny",
        description:
          "Extended laughter / the joke was ingeniously hilarious / “rolling on the ground” laughing"
      },
      %{
        digit: "y",
        title: "(optional)",
        description:
          "If the joke succeeds in amusing you, and seemed like a joke, but has any aspect(s) that do not make sense or are out of place, even in a joke."
      },
      %{
        digit: "z",
        title: "(optional)",
        description:
          "If the text is funny only because it failed so badly that it is funny (effectively it’s not a joke) (rate anyways)"
      }
    ]
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        How funny for your is this joke?
      </.header>

      <.form for={@form} id="rating-form" phx-change="validate" phx-submit="save">
        <p>{@joke.text}</p>
        <.input field={@form[:joke_id]} type="text" label="" value={@joke.id} hidden />
        <.input
          field={@form[:rating]}
          type="text"
          label="Rating (number+optional letter): "
          class="input w-16"
        />
        <.button phx-disable-with="Saving..." variant="primary">Submit rating</.button>
      </.form>
      <.table id="users" rows={rating_schema()}>
        <:col :let={r} label="">{r.digit}</:col>
        <:col :let={r} label="">{r.title}</:col>
        <:col :let={r} label="">{r.description}</:col>
      </.table>
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
    rating = Ratings.get_rating!(id)

    socket
    |> assign(:page_title, "Edit Rating")
    |> assign(:rating, rating)
    |> assign(:form, to_form(Ratings.change_rating(rating)))
  end

  defp apply_action(socket, :new, _params) do
    [joke_id | _] = Jokes.list_jokes_asc_rating(1)
    joke = Jokes.get_joke!(joke_id)
    rating = %Rating{}

    socket
    |> assign(:page_title, "New Joke Rating")
    |> assign(:joke, joke)
    |> assign(:rating, rating)
    |> assign(:form, to_form(Ratings.change_rating(rating)))
  end

  @impl true
  def handle_event("validate", %{"rating" => rating_params}, socket) do
    changeset = Ratings.change_rating(socket.assigns.rating, rating_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"rating" => rating_params}, socket) do
    save_rating(socket, socket.assigns.live_action, rating_params)
  end

  defp save_rating(socket, :edit, rating_params) do
    case Ratings.update_rating(socket.assigns.rating, rating_params) do
      {:ok, rating} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Rating updated successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, rating))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_rating(socket, :new, rating_params) do
    case Ratings.create_rating(rating_params) do
      {:ok, rating} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rating created successfully")
         |> push_navigate(to: ~p"/ratings/new")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _rating), do: ~p"/ratings"
  defp return_path("show", rating), do: ~p"/ratings/#{rating}"
end
