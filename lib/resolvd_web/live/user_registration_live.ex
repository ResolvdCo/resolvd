defmodule ResolvdWeb.UserRegistrationLive do
  use ResolvdWeb, :live_view

  alias Resolvd.Accounts
  alias Resolvd.Tenants
  alias Resolvd.Tenants.TenantCreation

  def render(assigns) do
    ~H"""
    <div class="relative pt-24 mx-auto max-w-sm">
      <.header class="text-center">
        Sign up for Resolv'd
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input
          field={@form[:company_name]}
          type="text"
          label="Company Name"
          required
          autofocus
          placeholder="Your Company"
        />
        <small>
          We'll use this to create <code><%= @slug %>.resolvd.app</code>, but you'll be able to setup a custom domain after you register.
        </small>
        <.input
          field={@form[:full_name]}
          type="text"
          label="Your Name"
          required
          placeholder="Jane Doe"
        />
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = TenantCreation.changeset(%TenantCreation{}, %{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(slug: "your-company")
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Tenants.create_tenant(TenantCreation.changeset(%TenantCreation{}, user_params)) do
      {:ok, tenant, user} ->
        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = TenantCreation.changeset(%TenantCreation{}, user_params)

    {:noreply,
     socket
     |> assign(:slug, slug_or_default(user_params))
     |> assign_form(Map.put(changeset, :action, :validate))}
  end

  defp slug_or_default(%{"company_name" => name}) when is_binary(name) and name != "",
    do: Slug.slugify(name)

  defp slug_or_default(_), do: Slug.slugify("your-company")

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
