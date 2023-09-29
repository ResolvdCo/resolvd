defmodule ResolvdWeb.StripeHandler do
  @behaviour Stripe.WebhookHandler

  @impl true
  def handle_event(%Stripe.Event{
        type: "checkout.session.completed",
        data: %{object: %Stripe.Session{} = session}
      }) do
    if session.payment_status == "paid" do
      %{"tenant_id" => tenant_id} = session.metadata
      tenant = Resolvd.Tenants.get_tenant!(tenant_id)
      Resolvd.Billing.finish_subscription(tenant, session)
    end

    :ok
  end

  # Return HTTP 200 for unhandled events
  @impl true
  def handle_event(_event), do: :ok
end
