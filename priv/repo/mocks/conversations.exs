num_conversations = 100

import Ecto.Query

tenant = Resolvd.Repo.one(from t in Resolvd.Tenants.Tenant, order_by: [asc: t.id], limit: 1)
user = Resolvd.Repo.one(from u in Resolvd.Accounts.User, where: u.tenant_id == ^tenant.id, order_by: [asc: u.id], limit: 1)
mailbox = Resolvd.Mailboxes.list_mailboxes(user) |> hd()
last_month = DateTime.utc_now() |> DateTime.add(-31, :day)

for n <- 1..num_conversations do
  body = Faker.Lorem.paragraphs(2..3) |> Enum.join("\n")
  random_date = last_month
    |> DateTime.add(Enum.random(1..30), :day)
    |> DateTime.add(Enum.random(1..5), :hour)
    |> DateTime.add(Enum.random(1..30), :minute)

  {:ok, conversation} = Resolvd.Conversations.create_or_update_conversation_from_email(
    mailbox,
    %Resolvd.Mailboxes.Mail{
      text_body: body,
      date: random_date,
      message_id: to_string(:smtp_util.generate_message_id()),
      sender: Faker.Internet.safe_email(),
      subject: Faker.Lorem.sentence(5, ""),
      to: mailbox.email_address
    }
  )

  conversation
  |> Ecto.Changeset.change(created_at: random_date)
  Resolvd.Repo.update()
end
