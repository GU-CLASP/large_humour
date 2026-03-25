defmodule LargeHumourWeb.ConsentLive do
  use LargeHumourWeb, :live_view
  import Ecto.UUID

  @impl true
  def render(assigns) do
    no_consent =
      case assigns.prolific_pid do
        <<"A_", _rest::binary>> ->
          "If you do not wish to participate in this study, please close this page."

        _ ->
          "If you do not wish to participate in this study, please close this page and return your submission on Prolific by selecting the “Stop without completing” button."
      end

    ~H"""
    <Layouts.app_noauth flash={@flash}>
      <section class="m-5 p-5 rounded-md bg-slate-100 h-full" id="consent_form">
        <h1 class="text-2xl font-semibold mb-5" id="instructions">
          Consent form
        </h1>
        <article id="meat" class="text-xl">
          <p class="mb-3">
            In this task, you will be asked to read and rate a number of jokes.
          </p>
          <p class="mb-3">
            By clicking the "<strong>Yes, I consent.</strong>" button below, you acknowledge:
          </p>
          <ol class="list-disc pl-4 mb-5 *:py-1 *:me-2 ml-5">
            <li>You are at least 18 years of age.</li>
            <li>You are a fluent English speaker.</li>
            <li>Your participation in the study is voluntary.</li>
            <li>
              You are aware that you may choose to terminate your participation at any time for any reason.
            </li>
            <li>You are aware that you may contact us to withdraw your consent and your data.</li>
            <li>
              You are aware that the results of the study may be published in a journal/conference, with anonymized data, and no information can reveal your identity.
            </li>
          </ol>
          <.button
            id="consentclose"
            phx-click="consent"
            class="mt-7 ml-4 bg-slate-300 text-slate-900 py-2 px-5 rounded font-semibold hover:bg-amber-200 hover:border-lime-200 cursor-pointer"
          >
            Yes, I consent.
          </.button>
          <p class="mt-3 pl-4 text-sm font-semibold text-red-600">
            {no_consent}
          </p>
        </article>
      </section>
    </Layouts.app_noauth>
    """
  end

  @impl true
  def mount(%{"prolific_pid" => prolific_pid}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Consent form")
     |> assign(:prolific_pid, prolific_pid)}
  end

  @impl true
  def mount(_params, _session, socket) do
    prolific_pid = "A_" <> Ecto.UUID.generate()

    {:ok,
     socket
     |> assign(:page_title, "Consent form")
     |> assign(:prolific_pid, prolific_pid)}
  end

  @impl true
  def handle_event("consent", _, socket) do
    {:noreply,
     socket
     |> push_navigate(to: ~p"/ratings/new?prolific_pid=#{socket.assigns.prolific_pid}")}
  end
end
