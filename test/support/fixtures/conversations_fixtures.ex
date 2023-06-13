defmodule Resolvd.ConversationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Conversations` context.
  """

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(attrs \\ %{}) do
    {:ok, conversation} =
      attrs
      |> Enum.into(%{
        body: 42,
        subject: "some subject"
      })
      |> Resolvd.Conversations.create_conversation()

    conversation
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Resolvd.Conversations.create_message()

    message
  end
end
