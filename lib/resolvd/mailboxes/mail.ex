defmodule Resolvd.Mailboxes.Mail do
  @moduledoc false

  @typedoc """
  The first field is the name associated with the address, and the second field is the address itself.
  e.g. `{"Bart", "bart@simpsons.family"}`
  """
  @type address :: {nil | String.t(), String.t()}

  @typedoc """
  e.g. `"text/html"`, `"image/png"`, `"text/plain"`, etc.

  For more, see this [list of MIME types](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types).
  """
  @type mime_type :: String.t()

  @typedoc """
  A body can be either "onepart" or "multipart".

  A "onepart" body is a tuple in the form `{mime_type, params, content}`, where `mime_type` is a [`mime_type`](`t:mime_type/0`),
  `params` is a string->string map, and `content` is a [`binary`](`t:binary/0`).

  A "multipart" body consists of a *list* of [`body`s](`t:body/0`), which can themselves be either onepart or multipart.
  """
  @type body :: {mime_type, %{optional(String.t()) => String.t()}, binary} | [body]

  @type flag :: :seen | :answered | :flagged | :draft | :deleted

  @type t :: %Resolvd.Mailboxes.Mail{
          bcc: [address],
          text_body: String.t(),
          html_body: String.t(),
          cc: [address],
          date: DateTime.t(),
          flags: [flag],
          in_reply_to: nil | String.t(),
          message_id: nil | String.t(),
          reply_to: [address],
          sender: String.t(),
          from: [address],
          subject: nil | String.t(),
          to: [address]
        }
  defstruct [
    :bcc,
    :text_body,
    :html_body,
    :cc,
    :date,
    :flags,
    :in_reply_to,
    :message_id,
    :reply_to,
    :sender,
    :from,
    :subject,
    :to
  ]

  def from_yugo_type(mail) do
    mail =
      Map.merge(%__MODULE__{}, mail)
      |> Map.delete(:body)
      |> Map.put(:html_body, get_body(mail.body, "text/html"))
      |> Map.put(:text_body, get_body(mail.body, "text/plain"))
      |> Map.put(:sender, mail.sender |> hd |> elem(1))

    case mail do
      %__MODULE__{html_body: nil, text_body: nil} ->
        raise "Email has neither text or html body"

      _ ->
        mail
    end
  end

  def get_body({found_mime, _charset, body}, mime) when found_mime == mime do
    body
  end

  def get_body(bodies, mime) when is_list(bodies) do
    Enum.find_value(bodies, fn raw ->
      case raw do
        # Try and find the mime we want
        {^mime, _charset, body} ->
          body

        # A multipart body can itself be nested
        multipart when is_list(multipart) ->
          get_body(multipart, mime)

        # Ignores all other types
        _ ->
          nil
      end
    end)
  end

  def get_body(_body, _mime) do
    # Ignores all other types
    nil
  end
end
