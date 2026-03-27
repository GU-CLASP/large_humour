defmodule LargeHumourWeb.RatingLive.Form do
  use LargeHumourWeb, :live_view
  require Logger

  alias LargeHumour.Ratings
  alias LargeHumour.Ratings.Rating
  alias LargeHumour.Jokes
  alias LargeHumour.Tasks

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
      }
    ]
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app_noauth flash={@flash}>
      <.header>
        How funny for you is this joke?
      </.header>

      <.form for={@form} id="rating-form" phx-change="validate" phx-submit="save">
        <div class="card shadow-sm bg-base-200">
          <div class="card-body">
            <p>{@joke.text}</p>
          </div>
        </div>
        <.input field={@form[:joke_id]} type="text" label="" value={@joke.id} hidden />
        <div class="w-full">
          <.input
            field={@form[:rating]}
            type="range"
            min="0"
            max="6"
            value="0"
            class="range w-full"
            step="1"
          />
          <div class="flex justify-between px-2.5 mt-2 text-xs">
            <%= for r <- rating_schema() do %>
              <div
                class="tooltip tooltip-bottom"
                data-tip={r.description}
              >
                <span>{r.digit}</span>
              </div>
            <% end %>
          </div>
        </div>
        <.table id="users" rows={rating_schema()}>
          <:col :let={r} label="" class="text-base-content/70">{r.digit}</:col>
          <:col :let={r} label="">{r.title}</:col>
          <:col :let={r} label="">{r.description}</:col>
        </.table>

        <fieldset class="fieldset bg-base-100 border-base-300 rounded-box w-full border p-4 mt-3 mb-3">
          <legend class="fieldset-legend">Additional questions:</legend>
          <div>
            <.input
              name="y"
              type="checkbox"
              label="Some aspects do not make sense or are out of place, even for a joke."
            />
            <div class="not-peer-has-checked:hidden">
              <.input
                field={@form[:weird_aspects]}
                type="text"
                placeholder="Specify which aspects..."
                class="input w-full"
              />
            </div>
          </div>
          <.input
            field={@form[:failed]}
            type="checkbox"
            label="It is funny only because it failed so badly that it is funny (effectively it’s not a joke)"
          />
          <.input
            field={@form[:offensive]}
            type="checkbox"
            label="I find this joke offensive"
          />
        </fieldset>
        <.button phx-disable-with="Saving..." variant="primary">Submit rating</.button>
      </.form>
    </Layouts.app_noauth>
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

  defp apply_action(socket, :new, %{
         "prolific_pid" => prolific_pid
       }) do
    create_tasks_for_rater!(prolific_pid, 10)

    case Tasks.list_unrated_jokes(prolific_pid) do
      [joke_id | _] ->
        joke = Jokes.get_joke!(joke_id)
        rating = %Rating{}

        socket
        |> assign(:page_title, "New Joke Rating")
        |> assign(:joke, joke)
        |> assign(:rating, rating)
        |> assign(:rater_id, prolific_pid)
        |> assign(:form, to_form(Ratings.change_rating(rating)))

      [] ->
        case prolific_pid do
          <<"A_", _rest::binary>> ->
            socket
            |> put_flash(:info, "Thank you! All jokes are now rated!")
            |> push_navigate(to: ~p"/thanks")

          _ ->
            link = Application.fetch_env!(:large_humour, :prolific_redirect_url)

            socket
            |> put_flash(:info, "Thank you! All jokes are now rated!")
            |> redirect(external: link)
        end
    end
  end

  def create_tasks_for_rater!(rater_id, max_ratings) do
    if Tasks.no_tasks?(rater_id) do
      Logger.info("Creating tasks for rater: #{rater_id}...")

      [seed_id | _] =
        Jokes.list_jokes(111_111, true)
        |> Enum.filter(fn {_, n} -> n < max_ratings end)
        |> Enum.map(fn {id, _} -> id end)

      ids =
        Jokes.list_jokes(111_111, false, seed_id)
        |> Enum.filter(fn {_, n} -> n < max_ratings end)
        |> Enum.map(fn {id, _} -> id end)
        |> Enum.slice(0..10)

      for j_id <- Enum.shuffle([seed_id | ids]) do
        Tasks.create_task(%{"rater_id" => rater_id, "joke_id" => j_id})
      end
    else
      Logger.info("Fetching tasks for rater: #{rater_id}...")
    end
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
    params = Map.put(rating_params, "rater_id", socket.assigns.rater_id)

    case Ratings.create_rating(params) do
      {:ok, rating} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rating submitted successfully")
         |> push_navigate(to: ~p"/ratings/new?prolific_pid=#{socket.assigns.rater_id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _rating), do: ~p"/ratings"
  defp return_path("show", rating), do: ~p"/ratings/#{rating}"
end
