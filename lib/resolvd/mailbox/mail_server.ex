defmodule Resolvd.Mailbox.MailServer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mail_servers" do
    belongs_to :tenant, Resolvd.Tenants.Tenant

    field :inbound_type, :string
    embeds_one :inbound_config, Resolvd.Mailbox.InboundProviders.IMAPProvider, on_replace: :update

    field :outbound_type, :string

    embeds_one :outbound_config, Resolvd.Mailbox.OutboundProviders.SMTPProvider,
      on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(mail_server, attrs) do
    mail_server
    |> cast(attrs, [])
    |> put_change(:inbound_type, "IMAP")
    |> cast_embed(:inbound_config,
      with: &Resolvd.Mailbox.InboundProviders.IMAPProvider.changeset/2
    )
    |> put_change(:outbound_type, "SMTP")
    |> cast_embed(:outbound_config,
      with: &Resolvd.Mailbox.OutboundProviders.SMTPProvider.changeset/2
    )
  end
end
