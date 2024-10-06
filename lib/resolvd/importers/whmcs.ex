defmodule Resolvd.Importers.WHMCS.Client do
  use Ecto.Schema

  schema "tblclients" do
    field :firstname, :string
    field :lastname, :string
    field :email, :string
  end
end

defmodule Resolvd.Importers.WHMCS.Ticket do
  use Ecto.Schema

  schema "tbltickets" do
    field :title, :string
    field :date, :naive_datetime
    field :message, :string
    field :status, :string
    field :urgency, :string
    belongs_to :client, Resolvd.Importers.WHMCS.Client, foreign_key: :userid
    has_many :replies, Resolvd.Importers.WHMCS.TicketReply, foreign_key: :tid
  end
end

defmodule Resolvd.Importers.WHMCS.TicketReply do
  use Ecto.Schema

  schema "tblticketreplies" do
    belongs_to :ticket, Resolvd.Importers.WHMCS.Ticket, foreign_key: :tid
    field :date, :naive_datetime
    field :message, :string
    belongs_to :client, Resolvd.Importers.WHMCS.Client, foreign_key: :userid
  end
end

defmodule Resolvd.Importers.WHMCS do
  import Ecto.Query

  alias Resolvd.Customers.Customer
  alias Resolvd.Conversations.{Conversation, Message}

  def import do
    # Resolvd.Importers.MySQL.start_link(
    #   name: :whmcs_import,
    #   hostname: "localhost",
    #   username: "root",
    #   database: "homenode",
    #   pool_size: 1
    # )

    # Resolvd.Importers.MySQL.all(Ticket) |> dbg()

    credentials = [
      hostname: "localhost",
      username: "root",
      database: "homenode"
    ]

    tenant = Resolvd.Repo.one(from t in Resolvd.Tenants.Tenant, order_by: [asc: t.id], limit: 1)

    user =
      Resolvd.Repo.one(
        from u in Resolvd.Accounts.User,
          where: u.tenant_id == ^tenant.id,
          order_by: [asc: u.id],
          limit: 1
      )

    mailbox = Resolvd.Mailboxes.get_mailbox!("fa2c5c9c-bf2a-41b3-bf1a-c2832570b8f9")

    Resolvd.Importers.MySQL.with_dynamic_repo(credentials, fn ->
      Resolvd.Importers.MySQL.all(Resolvd.Importers.WHMCS.Ticket)
      |> Resolvd.Importers.MySQL.preload([:client, [replies: [:client]]])
      |> Enum.map(fn %Resolvd.Importers.WHMCS.Ticket{} = ticket ->
        Ecto.Multi.new()
        |> Ecto.Multi.run(:maybe_customer, fn repo, _changes ->
          {:ok,
           Resolvd.Customers.get_customer_by_email(tenant, ticket.client.email) ||
             %Customer{tenant: tenant}}
        end)
        |> Ecto.Multi.insert_or_update(:customer, fn %{maybe_customer: maybe_customer} ->
          maybe_customer
          |> Customer.changeset(%{
            email: ticket.client.email,
            name: ticket.client.firstname <> " " <> ticket.client.lastname
          })
        end)
        |> Ecto.Multi.insert(:conversation, fn %{customer: customer} ->
          %Conversation{
            tenant: tenant,
            mailbox: mailbox,
            customer: customer,
            inserted_at: ticket.date
          }
          |> Conversation.changeset(%{
            subject: ticket.title,
            is_prioritized: ticket.urgency in ["High"]
          })
        end)
        |> Ecto.Multi.insert_all(:messages, Message, fn %{
                                                          conversation: conversation,
                                                          customer: customer
                                                        } ->
          replies =
            Enum.map(ticket.replies, fn %Resolvd.Importers.WHMCS.TicketReply{} = reply ->
              if reply.client do
                %{
                  conversation_id: conversation.id,
                  customer_id: customer.id,
                  email_message_id: "whmcs-import-#{ticket.id}-#{reply.id}",
                  text_body: reply.message,
                  html_body: reply.message,
                  inserted_at: reply.date,
                  updated_at: reply.date
                }
              else
                %{
                  conversation_id: conversation.id,
                  user_id: user.id,
                  email_message_id: "whmcs-import-#{ticket.id}-#{reply.id}",
                  text_body: reply.message,
                  html_body: reply.message,
                  inserted_at: reply.date,
                  updated_at: reply.date
                }
              end
            end)

          [
            %{
              conversation_id: conversation.id,
              customer_id: customer.id,
              email_message_id: "whmcs-import-#{ticket.id}",
              text_body: ticket.message,
              html_body: ticket.message,
              inserted_at: ticket.date,
              updated_at: ticket.date
            }
          ] ++ replies
        end)
        |> Resolvd.Repo.transaction()
      end)
    end)
  end
end

defmodule Resolvd.Importers.MySQL do
  use Ecto.Repo,
    otp_app: :resolvd,
    adapter: Ecto.Adapters.MyXQL,
    read_only: true

  def with_dynamic_repo(credentials, callback) do
    default_dynamic_repo = get_dynamic_repo()
    start_opts = [name: nil, pool_size: 1] ++ credentials
    {:ok, repo} = Resolvd.Importers.MySQL.start_link(start_opts)

    try do
      Resolvd.Importers.MySQL.put_dynamic_repo(repo)
      callback.()
    after
      Resolvd.Importers.MySQL.put_dynamic_repo(default_dynamic_repo)
      Supervisor.stop(repo)
    end
  end
end
