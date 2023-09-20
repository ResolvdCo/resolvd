defmodule Resolvd.Mailboxes.OutboundProviders.SMTPProvider do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  @derive Jason.Encoder
  embedded_schema do
    field :server, :string
    field :username, :string
    field :password, :string
    field :ssl, :boolean, default: true
    field :tls, :string, default: "if_available"
    field :auth, :string, default: "always"
    field :port, :integer, default: 465
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [:server, :username, :password, :port, :tls])
    |> validate_required([:server, :username, :password])
    |> validate_inclusion(:tls, ["always", "never", "if_available"])
    |> validate_inclusion(:auth, ["always", "never", "if_available"])
  end
end
