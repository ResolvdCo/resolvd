defmodule Resolvd.Conversations.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :text_body, :string
    field :html_body, :string
    field :email_message_id, :string

    belongs_to :conversation, Resolvd.Conversations.Conversation

    belongs_to :customer, Resolvd.Customers.Customer

    belongs_to :user, Resolvd.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text_body, :html_body, :email_message_id])
    |> cast_assoc(:customer)
  end
end
