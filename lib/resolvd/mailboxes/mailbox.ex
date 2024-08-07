defmodule Resolvd.Mailboxes.Mailbox do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query, only: [from: 2]
  @behaviour Bodyguard.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mailboxes" do
    field :name, :string
    field :from, :string
    field :email_address, :string

    belongs_to :tenant, Resolvd.Tenants.Tenant

    field :inbound_type, :string

    embeds_one :inbound_config, Resolvd.Mailboxes.InboundProviders.IMAPProvider,
      on_replace: :update

    field :outbound_type, :string

    embeds_one :outbound_config, Resolvd.Mailboxes.OutboundProviders.SMTPProvider,
      on_replace: :update

    has_many :conversations, Resolvd.Conversations.Conversation

    timestamps()
  end

  def scope(query, %Resolvd.Accounts.User{tenant_id: tenant_id}, _) do
    from q in query, where: q.tenant_id == ^tenant_id
  end

  @doc false
  def changeset(mailbox, attrs) do
    mailbox
    |> cast(attrs, [:name, :from, :email_address])
    |> put_change(:inbound_type, "IMAP")
    |> cast_embed(:inbound_config,
      with: &Resolvd.Mailboxes.InboundProviders.IMAPProvider.changeset/2
    )
    |> put_change(:outbound_type, "SMTP")
    |> cast_embed(:outbound_config,
      with: &Resolvd.Mailboxes.OutboundProviders.SMTPProvider.changeset/2
    )
  end
end
