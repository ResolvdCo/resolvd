defmodule Resolvd.Workers.SendCustomerEmail do
  use Oban.Worker, queue: :mailers, max_attempts: 1

  require Logger

  def perform(
        %Oban.Job{
          args: %{
            "conversation_id" => conversation_id,
            "mailbox_id" => mailbox_id,
            "headers" => %{"Message-ID" => message_id},
            "customer_email" => customer_email,
            "subject" => subject,
            "html_body" => html_body,
            "text_body" => text_body
          }
        } = params
      ) do
    Logger.info("Processing SendCustomerEmail for #{subject}")
    # For debugging, recv a mail, generate AI response, send mail back
    mailbox = Resolvd.Mailboxes.get_mailbox!(mailbox_id)

    conversation =
      Resolvd.Conversations.get_conversation!(conversation_id) |> Resolvd.Repo.preload(:messages)

    first_message = hd(conversation.messages)

    %{"content" => content} =
      Resolvd.TestingChatbot.OpenAI.call(first_message.text_body, text_body) |> dbg()

    # %{
    #   "content" => "I apologize for the confusion. The information displayed under \"top\" may not always accurately reflect the exact number of cores allocated to your VPS. Rest assured, your plan is configured with the correct resources as mentioned on the website. If you have any concerns or need further assistance, please feel free to reach out to our technical support team for clarification.",
    #   "refusal" => nil,
    #   "role" => "assistant"
    # }

    Resolvd.Mailboxes.process_customer_email(mailbox, %Resolvd.Mailboxes.Mail{
      text_body: content,
      html_body: content,
      date: DateTime.utc_now(),
      in_reply_to: message_id,
      message_id: to_string(:smtp_util.generate_message_id()),
      sender: customer_email,
      from: [{customer_email, customer_email}],
      subject: subject,
      to: [mailbox.email_address]
    })
    |> dbg()

    # email =
    #   Swoosh.Email.new(headers: headers)
    #   |> Swoosh.Email.to(customer_email)
    #   |> Swoosh.Email.subject(subject)
    #   |> Swoosh.Email.html_body(html_body)
    #   |> Swoosh.Email.text_body(text_body)

    # case Resolvd.Mailboxes.send_customer_email(mailbox, email) do
    #   {:ok, _metadata} ->
    #     Logger.info(
    #       "Successfully sent customer email: #{inspect(email)} with mailbox: #{inspect(email)}"
    #     )

    #   {:error, reason} ->
    #     Logger.error(
    #       "Error sending customer email: #{inspect(email)} with mailbox: #{inspect(email)}. Error: #{reason}"
    #     )
    # end

    Logger.info("Sending :ok")

    :ok
  end
end
