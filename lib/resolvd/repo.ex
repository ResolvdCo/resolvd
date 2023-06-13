defmodule Resolvd.Repo do
  use Ecto.Repo,
    otp_app: :resolvd,
    adapter: Ecto.Adapters.Postgres
end
