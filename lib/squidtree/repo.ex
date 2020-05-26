defmodule Squidtree.Repo do
  use Ecto.Repo,
    otp_app: :squidtree,
    adapter: Ecto.Adapters.Postgres
end
