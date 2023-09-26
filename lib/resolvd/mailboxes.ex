defmodule Resolvd.Mailboxes do
  import Ecto.Query, warn: false

  alias Resolvd.Repo
  alias Resolvd.Mailboxes.Mailbox
  alias Resolvd.Mailboxes.Inbound.Supervisor, as: InboundSupervisor
  alias Resolvd.Accounts.User

  def process_customer_email(%Mailbox{} = mailbox, %Resolvd.Mailboxes.Mail{} = email) do
    Resolvd.Conversations.create_or_update_conversation_from_email(mailbox, email)
  end

  def send_customer_email(%Mailbox{} = mailbox, %Swoosh.Email{} = email) do
    config = [
      adapter: Swoosh.Adapters.SMTP,
      relay: mailbox.outbound_config.server,
      username: mailbox.outbound_config.username,
      password: mailbox.outbound_config.password,
      # Temporary?
      ssl: false,
      tls: String.to_atom(mailbox.outbound_config.tls),
      auth: String.to_atom(mailbox.outbound_config.auth),
      port: mailbox.outbound_config.port,
      retries: 2,
      no_mx_lookups: false,
      tls_options: [
        versions: [:"tlsv1.3"],
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        server_name_indication: mailbox.outbound_config.server |> String.to_charlist(),
        depth: 99
      ]
    ]

    email
    |> Swoosh.Email.from({mailbox.from, mailbox.email_address})
    |> Swoosh.Mailer.deliver(config)
  end

  def list_inbound_types do
    %{
      :imap => "IMAP",
      :pop => "POP3"
    }
  end

  # def deliver(%Tenant{} = tenant, email) do
  #   outbound = get_outbound_provider(tenant)

  #   config = [
  #     adapter: Swoosh.Adapters.SMTP,
  #     relay: outbound.server,
  #     username: outbound.username,
  #     password: outbound.password,
  #     ssl: outbound.ssl,
  #     tls: outbound.tls,
  #     auth: outbound.auth,
  #     port: outbound.port
  #   ]

  #   with {:ok, metadata} <- Resolvd.Mailer.deliver(email, config) do
  #     nil
  #   end
  # end

  @doc """
  List mailboxes the user is allowed to see.

  ## Examples

      iex> list_mailboxes(user)
      [%Mailbox{}, ...]

  """
  def list_mailboxes(%User{} = user) do
    Mailbox
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  def get_mailbox!(id) do
    Mailbox
    |> where(id: ^id)
    |> Repo.one()
  end

  @doc """
  Gets a single mailbox.

  Raises `Ecto.NoResultsError` if the mailbox does not exist.

  ## Examples

      iex> get_mailbox!(user, 123)
      %Mailbox{}

      iex> get_mailbox!(user, 456)
      ** (Ecto.NoResultsError)

  """
  def get_mailbox!(%User{} = user, id) do
    Mailbox
    |> Bodyguard.scope(user)
    |> where(id: ^id)
    |> Repo.one()
  end

  @doc """
  Creates a mailbox.

  ## Examples

      iex> create_mailbox(%{field: value})
      {:ok, %Mailbox{}}

      iex> create_mailbox(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mailbox(%User{} = user, attrs \\ %{}) do
    %Mailbox{
      tenant_id: user.tenant_id
    }
    |> Mailbox.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mailbox.

  ## Examples

      iex> update_mailbox(mailbox, %{field: new_value})
      {:ok, %Mailbox{}}

      iex> update_mailbox(mailbox, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mailbox(%User{} = _user, %Mailbox{} = mailbox, attrs) do
    # raise "Permissions check"

    {:ok, server} =
      mailbox
      |> Mailbox.changeset(attrs)
      |> Repo.update()

    {:ok, server}
  end

  @doc """
  Deletes a mailbox.

  ## Examples

      iex> delete_mailbox(mailbox)
      {:ok, %Mailbox{}}

      iex> delete_mailbox(mailbox)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mailbox(%User{} = _user, %Mailbox{} = mailbox) do
    raise "Permissions check"
    Repo.delete(mailbox)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mailbox changes.

  ## Examples

      iex> change_mailbox(mailbox)
      %Ecto.Changeset{data: %Mailbox{}}

  """
  def change_mailbox(%Mailbox{} = mailbox, attrs \\ %{}) do
    Mailbox.changeset(mailbox, attrs)
  end

  def upstart_mailbox(%Mailbox{} = server) do
    if InboundSupervisor.child_started?(server.id) do
      stop_mailbox(server)
    end

    InboundSupervisor.start_child(server.id, server.inbound_config)
  end

  def stop_mailbox(%Mailbox{} = server) do
    InboundSupervisor.stop_child(server.id)
  end

  def mailbox_running?(%Mailbox{id: server_id}) do
    InboundSupervisor.child_started?(server_id)
  end

  # use GenServer

  # require Logger

  # def start_link(start_from, opts \\ []) do
  #   GenServer.start_link(__MODULE__, start_from, opts)
  # end

  # def init(start_from) do
  #   Yugo.subscribe(:resolvd)

  #   # started = NaiveDateTime.utc_now()

  #   # email =
  #   #   Swoosh.Email.new()
  #   #   |> Swoosh.Email.to("luke@axxim.net")
  #   #   |> Swoosh.Email.from({"Resolvd", "resolvd@axxim.net"})
  #   #   |> Swoosh.Email.subject("Server Started")
  #   #   |> Swoosh.Email.text_body("Server started at #{NaiveDateTime.to_string(started)}!")

  #   # Resolvd.Mailer.deliver(email) |> dbg()

  #   {:ok, %{start_from: start_from}}
  # end

  # def handle_info({:email, client, message}, state) do
  #   # client #=> :resolvd
  #   # message #=> %{
  #   #   bcc: [],
  #   #   body: [
  #   #     {"text/plain", %{"CHARSET" => "UTF-8"},
  #   #      "This is a test ticket!\r\n\r\nThanks,\r\nLuke Strickland\r\n"},
  #   #     {"text/html", %{"CHARSET" => "UTF-8"},
  #   #      "<div dir=\"ltr\"><div>This is a test ticket!</div><div><br></div><div><div><div dir=\"ltr\" class=\"gmail_signature\" data-smartmail=\"gmail_signature\"><div dir=\"ltr\"><font face=\"&#39;courier new&#39;, monospace\">Thanks,</font><div><font face=\"&#39;courier new&#39;, monospace\">Luke Strickland</font></div></div></div></div></div></div>\r\n"}
  #   #   ],
  #   #   cc: [],
  #   #   date: ~U[2023-05-12 05:30:19Z],
  #   #   flags: [],
  #   #   in_reply_to: nil,
  #   #   message_id: "<CAAEjmzwKXGLKHCN4CUF_EfxtCogqPcH9r2yfQTy1hgQfzg6gLg@mail.gmail.com>",
  #   #   reply_to: ["luke@axxim.net"],
  #   #   sender: ["luke@axxim.net"],
  #   #   subject: "Hello world",
  #   #   to: ["resolvd@axxim.net"]
  #   # }
  #   dbg(client)
  #   dbg(message)

  #   # Resolvd.Conversations.create_conversation(%{
  #   #   subject: message.subject,
  #   #   body: text_body(message.body)
  #   # })
  #   # |> dbg()

  #   email =
  #     Swoosh.Email.new()
  #     |> Swoosh.Email.to(message.reply_to)
  #     |> Swoosh.Email.from({"Resolvd", "aida@axxim.net"})
  #     |> Swoosh.Email.subject(message.subject)
  #     |> Swoosh.Email.text_body("We got your ticket bruv! Will respond soon.")
  #     |> Swoosh.Email.header("In-Reply-To", message.message_id)
  #     |> Swoosh.Email.header("References", message.message_id)

  #   Resolvd.Mailer.deliver(email) |> dbg()

  #   {:noreply, state}
  # end
end
