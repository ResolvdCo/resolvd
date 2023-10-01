defmodule Resolvd.Workers.SendUserEmail do
  use Oban.Worker, queue: :mailers

  alias Resolvd.Accounts.UserNotifier

  require Logger

  def perform(%Oban.Job{
        args: %{
          "action" => "deliver_confirmation_instructions",
          "user_email" => user_email,
          "url" => url
        }
      }) do
    case UserNotifier.deliver_confirmation_instructions(user_email, url) do
      {:ok, result} ->
        Logger.info("Successfully sent user confirmation instructions: #{inspect(result)}")

      {:error, reason} ->
        Logger.error("Error when sending user confirmation instructions: #{inspect(reason)}")
    end

    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "action" => "deliver_invite_instructions",
          "user_email" => user_email,
          "tenant_name" => tenant_name,
          "url" => url
        }
      }) do
    case UserNotifier.deliver_invite_instructions(user_email, tenant_name, url) do
      {:ok, result} ->
        Logger.info("Successfully sent user invite: #{inspect(result)}")

      {:error, reason} ->
        Logger.error("Error when sending user invite: #{inspect(reason)}")
    end

    :ok
  end

  def perform(%Oban.Job{
        args: %{
          "action" => "deliver_reset_password_instructions",
          "user_email" => user_email,
          "url" => url
        }
      }) do
    case UserNotifier.deliver_reset_password_instructions(user_email, url) do
      {:ok, result} ->
        Logger.info("Successfully sent user reset password instructions: #{inspect(result)}")

      {:error, reason} ->
        Logger.error("Error when sending user reset password instructions: #{inspect(reason)}")
    end

    :ok
  end

  def perform(%Oban.Job{
        args: %{
          "action" => "deliver_update_email_instructions",
          "user_email" => user_email,
          "url" => url
        }
      }) do
    case UserNotifier.deliver_update_email_instructions(user_email, url) do
      {:ok, result} ->
        Logger.info("Successfully sent user update email instructions: #{inspect(result)}")

      {:error, reason} ->
        Logger.error("Error when sending user update email instructions: #{inspect(reason)}")
    end

    :ok
  end
end
