defmodule Resolvd.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tenant_id, references(:tenants, type: :binary_id, on_delete: :delete_all), null: false

      add :name, :string
      add :email, :string
      add :phone, :string

      timestamps()
    end

    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tenant_id, references(:tenants, type: :binary_id, on_delete: :delete_all), null: false

      add :mailbox_id, references(:mailboxes, type: :binary_id, on_delete: :delete_all),
        null: false

      add :subject, :text

      add :customer_id, references(:customers, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps()
    end

    create index(:conversations, [:customer_id])

    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text_body, :text
      add :html_body, :text
      add :email_message_id, :string

      add :conversation_id, references(:conversations, on_delete: :delete_all, type: :binary_id)
      add :customer_id, references(:customers, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:messages, [:conversation_id])
  end
end
