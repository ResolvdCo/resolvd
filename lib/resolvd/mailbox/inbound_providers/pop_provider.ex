defmodule Resolvd.Mailbox.InboundProviders.POPProvider do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :server, :string
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [:server])
    |> validate_required([:server])
  end

  use Phoenix.Component
  import ResolvdWeb.CoreComponents

  attr :form, :any, required: true

  def inputs(assigns) do
    ~H"""
    <.input type="text" field={@form[:server]} label="Server" />
    """
  end
end
