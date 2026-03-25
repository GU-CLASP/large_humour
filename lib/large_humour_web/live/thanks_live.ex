defmodule LargeHumourWeb.ThanksLive do
  use LargeHumourWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app_noauth flash={@flash}>
      <section class="m-5 p-5 rounded-md bg-slate-100 h-full" id="consent_form">
        <h1 class="text-2xl font-semibold mb-5" id="instructions">
          Thank you for your participation!
        </h1>
        <article id="meat" class="text-xl">
          <p class="mb-3">
            You can close this page.
          </p>
        </article>
      </section>
    </Layouts.app_noauth>
    """
  end
end
