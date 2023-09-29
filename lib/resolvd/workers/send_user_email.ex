defmodule Resolvd.Workers.SendUserEmail do
  use Oban.Worker, queue: :mailers
  use ResolvdWeb, :verified_routes

  alias Resolvd.Accounts

  require Logger

  def perform(%Oban.Job{
        args: %{
          "action" => "confirmation_instructions",
          "user_id" => user_id,
          "user_email" => user_email,
          "confirmed_at" => confirmed_at
        }
      }) do
    user = %{id: user_id, email: user_email, confirmed_at: confirmed_at}

    case Accounts.deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}")) do
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
          "action" => "invite",
          "user_id" => user_id,
          "user_email" => user_email,
          "confirmed_at" => confirmed_at,
          "tenant_name" => tenant_name
        }
      }) do
    user = %{id: user_id, email: user_email, confirmed_at: confirmed_at}
    tenant = %{name: tenant_name}

    case Accounts.deliver_user_invite(user, tenant, &url(~p"/users/confirm/#{&1}")) do
      {:ok, result} ->
        Logger.info("Successfully sent user invite: #{inspect(result)}")

      {:error, reason} ->
        Logger.error("Error when sending user invite: #{inspect(reason)}")
    end

    :ok
  end

  def perform(%Oban.Job{
        args: %{
          "action" => "reset_password_instructions",
          "user_id" => user_id,
          "user_email" => user_email
        }
      }) do
    user = %{id: user_id, email: user_email}

    case Accounts.deliver_user_reset_password_instructions(
           user,
           &url(~p"/users/reset_password/#{&1}")
         ) do
      {:ok, result} ->
        Logger.info("Successfully sent user reset password instructions: #{inspect(result)}")

      {:error, reason} ->
        Logger.error("Error when sending user reset password instructions: #{inspect(reason)}")
    end

    :ok
  end

  def perform(%Oban.Job{
        args: %{
          "action" => "update_email_instructions",
          "user_id" => user_id,
          "user_email" => user_email,
          "current_email" => current_email
        }
      }) do
    user = %{id: user_id, email: user_email}

    case Accounts.deliver_user_update_email_instructions(
           user,
           current_email,
           &url(~p"/users/settings/confirm_email/#{&1}")
         ) do
      {:ok, result} ->
        Logger.info("Successfully sent user update email instructions: #{inspect(result)}")

      {:error, reason} ->
        Logger.error("Error when sending user update email instructions: #{inspect(reason)}")
    end

    :ok
  end
end
