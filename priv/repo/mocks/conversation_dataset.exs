import Ecto.Query

tenant = Resolvd.Repo.one(from t in Resolvd.Tenants.Tenant, order_by: [asc: t.id], limit: 1)

user =
  Resolvd.Repo.one(
    from u in Resolvd.Accounts.User,
      where: u.tenant_id == ^tenant.id,
      order_by: [asc: u.id],
      limit: 1
  )

mailbox = Resolvd.Mailboxes.list_mailboxes(user) |> hd()
last_month = DateTime.utc_now() |> DateTime.add(-31, :day)

"customer_support_tickets.csv"
|> File.stream!()
|> CSV.decode(headers: true, escape_max_lines: 50)
|> Enum.map(fn {:ok, ticket} ->
  random_date =
    last_month
    |> DateTime.add(Enum.random(1..30), :day)
    |> DateTime.add(Enum.random(1..5), :hour)
    |> DateTime.add(Enum.random(1..30), :minute)
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)

  {:ok, conversation} =
    Resolvd.Conversations.create_or_update_conversation_from_email(
      mailbox,
      %Resolvd.Mailboxes.Mail{
        text_body: ticket["Ticket Description"],
        date: random_date,
        message_id: to_string(:smtp_util.generate_message_id()),
        sender: ticket["Customer Email"],
        from: [{ticket["Customer Name"], ticket["Customer Email"]}],
        subject: ticket["Ticket Subject"],
        to: [{nil, mailbox.email_address}]
      }
    )

  conversation
  |> Ecto.Changeset.change(inserted_at: random_date)
  |> Resolvd.Repo.update()
end)
