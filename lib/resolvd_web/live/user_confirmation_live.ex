defmodule ResolvdWeb.UserConfirmationLive do
  use ResolvdWeb, :live_view

  alias Resolvd.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="relative pt-24 mx-auto max-w-sm">
      <.header class="text-center">Confirm Account</.header>

      <.simple_form
        for={@form}
        id="confirmation_form"
        phx-change="validate"
        phx-submit="confirm_account"
      >
        <.input field={@form[:token]} type="hidden" />

        <%= if is_nil(@user.hashed_password) do %>
          <p>You've been invited to join <%= @tenant.name %> on Resolvd.</p>
          <.input field={@form[:password]} type="password" label="New password" autofocus required />
          <.input field={@form[:password_confirmation]} type="password" label="Confirm new password" />
        <% end %>

        <:actions>
          <.button phx-disable-with="Confirming..." class="w-full">Confirm my account</.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "user")
    user = Accounts.get_user_by_email_verify_token(token)
    tenant = Resolvd.Tenants.get_tenant!(user.tenant_id)
    {:ok, assign(socket, form: form, user: user, tenant: tenant), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("validate", %{"user" => params}, socket) do
    changeset = Accounts.User.confirm_password_changeset(socket.assigns.user, params)

    {:noreply,
     socket
     |> assign_form(Map.put(changeset, :action, :validate))}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => %{"token" => token} = params}, socket) do
    case Accounts.confirm_user(token, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "User confirmed successfully.")
         |> redirect(to: ~p"/users/log_in")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
