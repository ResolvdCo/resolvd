defmodule ResolvdWeb.Admin.BillingLive do
  use ResolvdWeb, :admin_live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       payment_history: Resolvd.Billing.list_payment_history(socket.assigns.current_tenant),
       plan_status: socket.assigns.current_tenant.plan_status
     )}
  end

  @impl true
  def handle_params(%{"stripe_session_id" => stripe_session_id}, url, socket) do
    {:ok, session} = Stripe.Session.retrieve(stripe_session_id)
    Resolvd.Billing.finish_subscription(socket.assigns.current_tenant, session)

    {:noreply,
     socket
     |> assign(current_url: url)
     |> push_patch(to: ~p"/admin/billing", replace: true)
     |> put_flash(
       :info,
       "Your payment has been processed successfully, thank you for using Resolvd!"
     )}
  end

  def handle_params(_params, url, socket) do
    {:noreply, socket |> assign(current_url: url)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
      <%= if @current_tenant.plan_status == :canceling do %>
        <.warning>
          <p>
            Your subscription to Resolvd will expire on <%= format_datetime(
              @current_tenant.plan_expires
            ) %>. Resolvd will continue to store all of your historical data and accept new conversations, but you will not be able to respond to customers.
          </p>
          <br />
          <p>
            You can continue your subscription by clicking the Continue Subscription button below.
          </p>
        </.warning>
      <% end %>

      <div class="mx-auto mt-8 max-w-2xl rounded-3xl ring-1 ring-gray-200 sm:mt-10 lg:mx-0 lg:flex lg:max-w-none">
        <div class="p-8 sm:p-10 lg:flex-auto">
          <h3 class="text-2xl font-bold tracking-tight text-gray-900">Introductory Pricing</h3>
          <p class="mt-6 text-base leading-7 text-gray-600">
            Our limited time introductory pricing for customers before our official launch. Once we officially hit the Go button we'll switch to support seat based pricing.
          </p>
          <div class="mt-10 flex items-center gap-x-4">
            <h4 class="flex-none text-sm font-semibold leading-6 text-indigo-600">
              What’s included
            </h4>
            <div class="h-px flex-auto bg-gray-100"></div>
          </div>
          <ul
            role="list"
            class="mt-8 grid grid-cols-1 gap-4 text-sm leading-6 text-gray-600 sm:grid-cols-2 sm:gap-6"
          >
            <li class="flex gap-x-3">
              <svg
                class="h-6 w-5 flex-none text-indigo-600"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                  clip-rule="evenodd"
                />
              </svg>
              Unlimited conversations
            </li>
            <li class="flex gap-x-3">
              <svg
                class="h-6 w-5 flex-none text-indigo-600"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                  clip-rule="evenodd"
                />
              </svg>
              Knowledge Base
            </li>
            <li class="flex gap-x-3">
              <svg
                class="h-6 w-5 flex-none text-indigo-600"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                  clip-rule="evenodd"
                />
              </svg>
              Unlimited support users
            </li>
            <li class="flex gap-x-3">
              <svg
                class="h-6 w-5 flex-none text-indigo-600"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                  clip-rule="evenodd"
                />
              </svg>
              Dedicated onboarding
            </li>
          </ul>
        </div>
        <div class="-mt-2 p-2 lg:mt-0 lg:w-full lg:max-w-md lg:flex-shrink-0">
          <div class="rounded-2xl bg-gray-50 py-10 text-center ring-1 ring-inset ring-gray-900/5 lg:flex lg:flex-col lg:justify-center lg:py-16">
            <div class="mx-auto max-w-xs px-8">
              <%= if @current_tenant.plan_status == :active do %>
                <p class="text-base font-semibold text-gray-600">Your Current Plan</p>
              <% else %>
                <p class="text-base font-semibold text-gray-600">Simple Monthly Pricing</p>
              <% end %>
              <p class="mt-6 flex items-baseline justify-center gap-x-2">
                <span class="text-5xl font-bold tracking-tight text-gray-900">$30</span>
                <span class="text-sm font-semibold leading-6 tracking-wide text-gray-600">USD</span>
              </p>

              <.convert_button
                plan_status={@current_tenant.plan_status}
                plan_renewal={@current_tenant.plan_renewal}
              />

              <p class="mt-6 text-xs leading-5 text-gray-600">
                <%= if @current_tenant.plan_status == :active do %>
                  Renews on <%= format_datetime(@current_tenant.plan_renewal) %>
                <% else %>
                  Invoices and receipts available for easy company reimbursement
                <% end %>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <h2 class="text-lg font-semibold leading-7 text-zinc-800 mt-10">
      Payment History
    </h2>
    <.table id="payment-history" rows={@payment_history}>
      <:col :let={payment} label="Date / Time"><%= format_datetime(payment.created) %></:col>
      <:col :let={_payment} label="Plan">Introductory Pricing</:col>
      <:col :let={payment} label="Amount">$<%= format_price(payment.amount) %></:col>
      <:col :let={payment} label="Status"><%= String.capitalize(payment.status) %></:col>
      <:action :let={payment}>
        <%= unless payment.status == "failed" do %>
          <.link href={payment.receipt_url} target="_blank">Receipt</.link>
        <% end %>
      </:action>
    </.table>
    """
  end

  defp convert_button(%{plan_status: :active} = assigns) do
    ~H"""
    <.button
      phx-click="cancel_subscription"
      data-confirm={"Are you sure you want to cancel your subscription? Your final day will be #{format_datetime(@plan_renewal)}."}
      class="mt-10 block w-full"
    >
      Cancel Subscription
    </.button>
    """
  end

  defp convert_button(%{plan_status: :canceling} = assigns) do
    ~H"""
    <.button
      phx-click="resume_subscription"
      data-confirm={"Are you sure you wish to resubscribe? You will be charged on #{format_datetime(@plan_renewal)}."}
      class="mt-10 block w-full"
    >
      Continue Subscription
    </.button>
    """
  end

  defp convert_button(assigns) do
    ~H"""
    <a
      href="#"
      phx-click="start_subscription"
      class="mt-10 block w-full rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
    >
      Start Plan
    </a>
    """
  end

  @impl true
  def handle_event("start_subscription", _, socket) do
    plan = Resolvd.Billing.get_pricing(:introductory)

    case Resolvd.Billing.start_subscription(
           socket.assigns.current_tenant,
           plan,
           socket.assigns.current_url
         ) do
      {:ok, %Stripe.Session{url: url}} ->
        {:noreply, socket |> redirect(external: url)}

      error ->
        dbg(error)
        {:noreply, socket}
    end
  end

  def handle_event("cancel_subscription", _, socket) do
    case Resolvd.Billing.cancel_subscription(socket.assigns.current_tenant) do
      {:ok, tenant} ->
        {:noreply,
         socket
         |> assign(:current_tenant, tenant)
         |> put_flash(:info, "Successfully cancelled subscription.")}

      error ->
        dbg(error)
        {:noreply, socket}
    end
  end

  def handle_event("resume_subscription", _, socket) do
    case Resolvd.Billing.resume_subscription(socket.assigns.current_tenant) do
      {:ok, tenant} ->
        {:noreply,
         socket
         |> assign(:current_tenant, tenant)
         |> put_flash(:info, "Successfully renewed subscription.")}

      error ->
        dbg(error)
        {:noreply, socket}
    end
  end

  defp format_price(nil), do: "0.00"
  defp format_price(iprice), do: :erlang.float_to_binary(iprice / 100, decimals: 2)

  defp format_datetime(timestamp) when is_integer(timestamp) do
    format_datetime(DateTime.from_unix!(timestamp))
  end

  defp format_datetime(%{year: _, month: _, day: _y} = datetime) do
    Calendar.strftime(datetime, "%B %-d %Y")
  end

  defp format_datetime(_), do: "Unknown"
end
