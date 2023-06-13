defmodule Resolvd.Mailbox.InboundProviders.IMAPProvider do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field :server, :string
    field :username, :string
    field :password, :string
    field :port, :integer, default: 993
    field :tls, :boolean, default: true
    field :mailbox, :string, default: "INBOX"
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [:server, :username, :password, :port, :tls, :mailbox])
    |> validate_required([:server, :username, :password])
  end
end
