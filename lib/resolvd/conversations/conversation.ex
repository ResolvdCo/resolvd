defmodule Resolvd.Conversations.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "conversations" do
    field :subject, :string
    belongs_to :tenant, Resolvd.Tenants.Tenant

    has_many :messages, Resolvd.Conversations.Message
    belongs_to :user, Resolvd.Accounts.User
    belongs_to :customer, Resolvd.Customers.Customer

    timestamps()
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:subject])
    |> cast_assoc(:messages)
    |> cast_assoc(:customer)
    |> validate_required([:subject])
  end
end
