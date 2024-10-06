defmodule Resolvd.Mailboxes.OutboundProviders.LoggerProvider do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  @derive Jason.Encoder
  embedded_schema do
    field :log_full_email, :boolean
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [:log_full_email])
  end

  use Phoenix.Component

  def render(assigns) do
    ~H"""

    """
  end
end
