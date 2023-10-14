defmodule Resolvd.Accounts.UserNotifier do
  import Swoosh.Email

  alias Resolvd.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Resolvd", "support@resolvd.co"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user_email, url) do
    deliver(user_email, "Confirmation instructions", """

    ==============================

    Hi #{user_email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to sign up for a Resolvd account.
  """
  def deliver_invite_instructions(user_email, tenant_name, url) do
    deliver(user_email, "You've been invited to join #{tenant_name} on Resolvd", """
    Hi #{user_email},

    You've been invited you to join #{tenant_name} on Resolvd.

    To accept this invite click the URL below to setup your password:

    #{url}
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user_email, url) do
    deliver(user_email, "Reset password instructions", """

    ==============================

    Hi #{user_email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user_email, url) do
    deliver(user_email, "Update email instructions", """

    ==============================

    Hi #{user_email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
