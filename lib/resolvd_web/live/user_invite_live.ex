defmodule ResolvdWeb.UserInviteLive do
  use ResolvdWeb, :live_view

  alias Resolvd.Accounts

  def render(assigns) do
    ~H"""
    <div class="relative pt-24 mx-auto max-w-sm">
      <.header class="text-center">Join <%= @tenant.name %> on Resolvd</.header>

      <.simple_form
        for={@form}
        id="invite_form"
        phx-change="validate"
        phx-submit="confirm_account"
        method="post"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=accepted_invite"}
      >
        <.input field={@form[:token]} type="hidden" />
        <.input field={@form[:email]} type="hidden" />

        <p>You've been invited to join <%= @tenant.name %> on Resolvd. Please create a password:</p>
        <.input field={@form[:password]} type="password" label="Password" autofocus required />
        <.input field={@form[:password_confirmation]} type="password" label="Confirm password" />

        <:actions>
          <.button phx-disable-with="Confirming..." class="w-full">Create my account</.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4"><.link href={~p"/users/log_in"}>Log in</.link></p>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    case Resolvd.Accounts.get_user_by_email_verify_token(token) do
      %Resolvd.Accounts.User{} = user ->
        tenant = Resolvd.Tenants.get_tenant_for_user!(user)
        form = to_form(%{"token" => token, "email" => user.email}, as: "user")

        {:ok,
         socket
         |> assign(:form, form)
         |> assign(:user, user)
         |> assign(:tenant, tenant)
         |> assign(:trigger_submit, false), temporary_assigns: [form: nil]}

      _ ->
        {:ok,
         socket
         |> put_flash(:info, "Expired or invalid invite token.")
         |> redirect(to: ~p"/users/log_in")}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    form =
      socket.assigns.user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("confirm_account", %{"user" => user_params}, socket) do
    case Accounts.accept_invite(socket.assigns.user, user_params) do
      {:ok, user} ->
        user_params = Map.put(user_params, "email", user.email)

        form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, form: form)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
