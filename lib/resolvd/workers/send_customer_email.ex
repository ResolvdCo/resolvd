defmodule Resolvd.Workers.SendCustomerEmail do
  use Oban.Worker, queue: :mailers

  require Logger

  def perform(%Oban.Job{
        args: %{
          "mailbox_id" => mailbox_id,
          "headers" => headers,
          "customer_email" => customer_email,
          "subject" => subject,
          "html_body" => html_body,
          "text_body" => text_body
        }
      }) do
    mailbox = Resolvd.Mailboxes.get_mailbox!(mailbox_id)

    email =
      Swoosh.Email.new(headers: headers)
      |> Swoosh.Email.to(customer_email)
      |> Swoosh.Email.subject(subject)
      |> Swoosh.Email.html_body(html_body)
      |> Swoosh.Email.text_body(text_body)

    # case Map.fetch(args, "text_body") do
    #   {:ok, text_body} ->
    #     Swoosh.Email.text_body(email, text_body)

    #   :error ->
    #     email
    # end

    case Resolvd.Mailboxes.send_customer_email(mailbox, email) do
      {:ok, _metadata} ->
        Logger.info(
          "Successfully sent customer email: #{inspect(email)} with mailbox: #{inspect(email)}"
        )

      {:error, reason} ->
        Logger.error(
          "Error sending customer email: #{inspect(email)} with mailbox: #{inspect(email)}. Error: #{reason}"
        )
    end

    :ok
  end
end
