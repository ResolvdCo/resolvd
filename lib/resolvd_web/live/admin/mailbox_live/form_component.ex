defmodule ResolvdWeb.Admin.MailboxLive.FormComponent do
  use ResolvdWeb, :live_component

  alias Resolvd.Mailboxes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage mailbox records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="mailbox-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input type="text" field={@form[:name]} label="Name" />
        <.input type="text" field={@form[:from]} label="From" />
        <.input type="text" field={@form[:email_address]} label="Email Address" />
        <.inputs_for :let={input} field={@form[:inbound_config]}>
          <div class="border-b border-gray-900/10 pb-12">
            <h2 class="text-base font-semibold leading-7 text-gray-900">Incoming Mail</h2>
            <p class="mt-1 text-sm leading-6 text-gray-600">
              Use a permanent address where you can receive mail.
            </p>

            <div class="mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6">
              <div class="col-span-full">
                <.input type="text" field={input[:server]} label="Server" />
              </div>

              <div class="sm:col-span-3">
                <.input type="number" field={input[:port]} label="Port" />
              </div>

              <div class="sm:col-span-3">
                <label
                  for="mailbox_inbound_config_tls"
                  class="block text-sm font-medium leading-6 text-gray-900"
                >
                  TLS
                </label>
                <.input type="checkbox" field={input[:tls]} label="TLS" />
              </div>
              <div class="col-span-full">
                <.input type="text" field={input[:username]} label="Username" />
              </div>

              <div class="col-span-full">
                <.input type="password" field={input[:password]} label="Password" />
              </div>
            </div>
          </div>
        </.inputs_for>

        <.inputs_for :let={output} field={@form[:outbound_config]}>
          <div class="border-b border-gray-900/10 pb-12">
            <h2 class="text-base font-semibold leading-7 text-gray-900">Outgoing Mail</h2>
            <p class="mt-1 text-sm leading-6 text-gray-600">
              Use a permanent address where you can receive mail.
            </p>

            <div class="mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-12">
              <div class="col-span-full">
                <.input type="text" field={output[:server]} label="Server" />
              </div>

              <div class="sm:col-span-3 sm:col-start-1">
                <.input type="number" field={output[:port]} label="Port" />
              </div>
              <div class="sm:col-span-3">
                <.input type="checkbox" field={output[:ssl]} label="SSL" />
              </div>

              <div class="sm:col-span-3">
                <.input
                  type="select"
                  field={output[:tls]}
                  label="TLS"
                  options={["always", "never", "if_available"]}
                />
              </div>

              <div class="sm:col-span-3">
                <.input
                  type="select"
                  field={output[:auth]}
                  label="Auth"
                  options={["always", "never", "if_available"]}
                />
              </div>

              <div class="col-span-full">
                <.input type="text" field={output[:username]} label="Username" />
              </div>

              <div class="col-span-full">
                <.input type="password" field={output[:password]} label="Password" />
              </div>
            </div>
          </div>
        </.inputs_for>

        <.button phx-disable-with="Saving...">Save Mailbox</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{mailbox: mailbox} = assigns, socket) do
    changeset = Mailboxes.change_mailbox(mailbox)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:inbound_type, Resolvd.Mailboxes.InboundProviders.IMAPProvider)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"mailbox" => mailbox_params}, socket) do
    dbg(mailbox_params)

    changeset =
      socket.assigns.mailbox
      |> Mailboxes.change_mailbox(mailbox_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"mailbox" => mailbox_params}, socket) do
    save_mailbox(socket, socket.assigns.action, mailbox_params)
  end

  defp save_mailbox(socket, :edit, mailbox_params) do
    case Mailboxes.update_mailbox(
           socket.assigns.current_user,
           socket.assigns.mailbox,
           mailbox_params
         ) do
      {:ok, mailbox} ->
        notify_parent({:saved, mailbox})

        {:noreply,
         socket
         |> put_flash(:info, "Mailbox updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_mailbox(socket, :new, mailbox_params) do
    case Mailboxes.create_mailbox(socket.assigns.current_user, mailbox_params) do
      {:ok, mailbox} ->
        notify_parent({:saved, mailbox})

        {:noreply,
         socket
         |> put_flash(:info, "Mailbox created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
