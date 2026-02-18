defmodule LargeHumour.Repo do
  use Ecto.Repo,
    otp_app: :large_humour,
    adapter: Ecto.Adapters.Postgres
end
