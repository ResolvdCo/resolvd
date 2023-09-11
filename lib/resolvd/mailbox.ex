defmodule Resolvd.Mailbox do
  import Ecto.Query, warn: false

  alias Resolvd.Repo
  alias Resolvd.Mailbox.MailServer
  alias Resolvd.Mailbox.InboundSupervisor
  alias Resolvd.Tenants.Tenant

  def list_inbound_types do
    %{
      :imap => "IMAP",
      :pop => "POP3"
    }
  end

  def get_inbound_provider(provider) do
    Map.get(list_inbound_types(), provider)
  end

  def tenant_outbound_provider(%Tenant{} = tenant) do
    nil
  end

  def deliver(%Tenant{} = tenant, email) do
    outbound = tenant_outbound_provider(tenant)

    config = [
      adapter: Swoosh.Adapters.SMTP,
      relay: outbound.server,
      username: outbound.username,
      password: outbound.password,
      ssl: outbound.ssl,
      tls: outbound.tls,
      auth: outbound.auth,
      port: outbound.port
    ]

    with {:ok, metadata} <- Resolvd.Mailer.deliver(email, config) do
      nil
    end
  end

  @doc """
  Returns the list of mail_servers.

  ## Examples

      iex> list_mail_servers()
      [%MailServer{}, ...]

  """
  def list_mail_servers do
    Repo.all(MailServer)
  end

  @doc """
  Gets a single mail_server.

  Raises `Ecto.NoResultsError` if the Mail server does not exist.

  ## Examples

      iex> get_mail_server!(123)
      %MailServer{}

      iex> get_mail_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mail_server!(id), do: Repo.get!(MailServer, id)

  @doc """
  Creates a mail_server.

  ## Examples

      iex> create_mail_server(%{field: value})
      {:ok, %MailServer{}}

      iex> create_mail_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mail_server(attrs \\ %{}) do
    %MailServer{}
    |> MailServer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mail_server.

  ## Examples

      iex> update_mail_server(mail_server, %{field: new_value})
      {:ok, %MailServer{}}

      iex> update_mail_server(mail_server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mail_server(%MailServer{} = mail_server, attrs) do
    {:ok, server} =
      mail_server
      |> MailServer.changeset(attrs)
      |> Repo.update()

    {:ok, server}
  end

  @doc """
  Deletes a mail_server.

  ## Examples

      iex> delete_mail_server(mail_server)
      {:ok, %MailServer{}}

      iex> delete_mail_server(mail_server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mail_server(%MailServer{} = mail_server) do
    Repo.delete(mail_server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mail_server changes.

  ## Examples

      iex> change_mail_server(mail_server)
      %Ecto.Changeset{data: %MailServer{}}

  """
  def change_mail_server(%MailServer{} = mail_server, attrs \\ %{}) do
    MailServer.changeset(mail_server, attrs)
  end

  def upstart_mail_server(%MailServer{} = server) do
    if InboundSupervisor.child_started?(server.id) do
      stop_mail_server(server)
    end

    InboundSupervisor.start_child(server.id, server.inbound_config)
  end

  def stop_mail_server(%MailServer{} = server) do
    InboundSupervisor.stop_child(server.id)
  end

  def mail_server_running?(%MailServer{id: server_id}) do
    InboundSupervisor.child_started?(server_id) |> dbg()
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
