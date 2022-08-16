defmodule Relayd.Repo do
  use Ecto.Repo,
    otp_app: :relayd,
    adapter: Ecto.Adapters.Postgres
end
