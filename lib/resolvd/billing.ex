defmodule Resolvd.Billing do
  alias Resolvd.Tenants.Tenant

  defmodule Plan do
    defstruct [:product_id, :price_id, :price_display]
  end

  def get_pricing(type) do
    case Application.get_env(:resolvd, Resolvd.Billing) do
      [plans: plans] ->
        struct(Resolvd.Billing.Plan, Map.get(plans, type))

      nil ->
        %{}
    end
  end

  def list_payment_history(%Tenant{stripe_customer_id: nil}), do: []

  def list_payment_history(%Tenant{stripe_customer_id: stripe_customer_id}) do
    {:ok, payment_history} = Stripe.Charge.list(%{customer: stripe_customer_id})

    payment_history.data
  end

  def start_subscription(
        %Resolvd.Tenants.Tenant{} = tenant,
        %Resolvd.Billing.Plan{} = plan,
        return_url
      ) do
    stripe_input = %{
      "cancel_url" => return_url,
      "success_url" => return_url <> "?stripe_session_id={CHECKOUT_SESSION_ID}",
      "mode" => "subscription",
      "payment_method_types" => [
        "card"
      ],
      "line_items" => [
        %{
          "price" => plan.price_id,
          "quantity" => 1
        }
      ],
      "metadata" => %{
        "tenant_id" => tenant.id
      }
    }

    Stripe.Session.create(stripe_input)
  end

  @doc """
  Complete the checkout for the tenant. For now we'll rely on Stripe to maintain our data, and only activate certain tenant fields. In the future we'll want to store more of this locally.
  """
  def finish_subscription(%Tenant{} = tenant, %Stripe.Session{} = session) do
    case Stripe.Subscription.retrieve(session.subscription) do
      {:ok, %Stripe.Subscription{} = subscription} ->
        Resolvd.Tenants.update_billing(tenant, %{
          plan_status: :active,
          plan_renewal: subscription.current_period_end |> DateTime.from_unix!(),
          plan_expires: nil,
          stripe_subscription_id: subscription.id,
          stripe_customer_id: session.customer
        })

      other ->
        other
    end
  end

  def cancel_subscription(%Tenant{plan_status: :active} = tenant) do
    case Stripe.Subscription.update(tenant.stripe_subscription_id, %{cancel_at_period_end: true}) do
      {:ok, _} ->
        Resolvd.Tenants.update_billing(tenant, %{
          plan_status: :canceling,
          plan_expires: tenant.plan_renewal
        })

      other ->
        other
    end
  end

  def resume_subscription(%Tenant{plan_status: :canceling} = tenant) do
    case Stripe.Subscription.update(tenant.stripe_subscription_id, %{cancel_at_period_end: false}) do
      {:ok, _} ->
        Resolvd.Tenants.update_billing(tenant, %{
          plan_status: :active,
          plan_expires: nil
        })

      other ->
        other
    end
  end
end
