defmodule Resolvd.Conversations.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "conversations" do
    field :subject, :string

    has_many :messages, Resolvd.Conversations.Message

    belongs_to :tenant, Resolvd.Tenants.Tenant

    belongs_to :customer, Resolvd.Customers.Customer

    belongs_to :user, Resolvd.Accounts.User

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
