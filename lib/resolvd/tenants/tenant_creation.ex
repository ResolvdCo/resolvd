defmodule Resolvd.Tenants.TenantCreation do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :company_name, :string
    field :full_name, :string
    field :email, :string
    field :password, :string
  end

  def changeset(myself, attrs) do
    myself
    |> cast(attrs, [:company_name, :full_name, :email, :password])
    |> validate_email()
    |> validate_password()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)

    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
  end
end
