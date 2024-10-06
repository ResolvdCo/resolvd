defmodule Resolvd.Conversations.ConversationNotifier do
  import Swoosh.Email

  alias Resolvd.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body, message_id) do
    email =
      new(headers: %{"Message-ID" => message_id})
      |> to(recipient)
      |> from({"Resolvd", "notifier@resolvd.co"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_message_with_id(user, message, message_id) do
    deliver(user.email, "Some message", message, message_id)
  end
end
