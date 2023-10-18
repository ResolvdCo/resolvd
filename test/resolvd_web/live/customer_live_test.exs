# defmodule ResolvdWeb.CustomerLiveTest do
#   use ResolvdWeb.ConnCase

#   import Phoenix.LiveViewTest
#   import Resolvd.AccountsFixtures
#   import Resolvd.CustomersFixtures

#   @create_attrs %{email: "some email", name: "some name", phone: "some phone"}
#   @update_attrs %{
#     email: "some updated email",
#     name: "some updated name",
#     phone: "some updated phone"
#   }
#   @invalid_attrs %{email: nil, name: nil, phone: nil}

#   defp create_customer(_) do
#     tenant = tenant_fixture()
#     customer = customer_fixture(tenant)
#     %{customer: customer}
#   end

#   describe "Index" do
#     setup [:register_and_log_in_user, :create_customer]

#     test "lists all customers", %{conn: conn, customer: customer} do
#       {:ok, _index_live, html} = live(conn, ~p"/customers")

#       assert html =~ "Customers"
#       assert html =~ customer.email
#     end

#     test "saves new customer", %{conn: conn} do
#       {:ok, index_live, _html} = live(conn, ~p"/customers")

#       assert index_live |> element("a", "New Customer") |> render_click() =~
#                "New Customer"

#       assert_patch(index_live, ~p"/customers/new")

#       assert index_live
#              |> form("#customer-form", customer: @invalid_attrs)
#              |> render_change() =~ "can&#39;t be blank"

#       assert index_live
#              |> form("#customer-form", customer: @create_attrs)
#              |> render_submit()

#       assert_patch(index_live, ~p"/customers")

#       html = render(index_live)
#       assert html =~ "Customer created successfully"
#       assert html =~ "some email"
#     end

#     test "updates customer in listing", %{conn: conn, customer: customer} do
#       {:ok, index_live, _html} = live(conn, ~p"/customers")

#       assert index_live |> element("#customers-#{customer.id} a", "Edit") |> render_click() =~
#                "Edit Customer"

#       assert_patch(index_live, ~p"/customers/#{customer}/edit")

#       assert index_live
#              |> form("#customer-form", customer: @invalid_attrs)
#              |> render_change() =~ "can&#39;t be blank"

#       assert index_live
#              |> form("#customer-form", customer: @update_attrs)
#              |> render_submit()

#       assert_patch(index_live, ~p"/customers")

#       html = render(index_live)
#       assert html =~ "Customer updated successfully"
#       assert html =~ "some updated email"
#     end

#     test "deletes customer in listing", %{conn: conn, customer: customer} do
#       {:ok, index_live, _html} = live(conn, ~p"/customers")

#       assert index_live |> element("#customers-#{customer.id} a", "Delete") |> render_click()
#       refute has_element?(index_live, "#customers-#{customer.id}")
#     end
#   end

#   describe "Show" do
#     setup [:create_customer]

#     test "displays customer", %{conn: conn, customer: customer} do
#       {:ok, _show_live, html} = live(conn, ~p"/customers/#{customer}")

#       assert html =~ "Show Customer"
#       assert html =~ customer.email
#     end

#     test "updates customer within modal", %{conn: conn, customer: customer} do
#       {:ok, show_live, _html} = live(conn, ~p"/customers/#{customer}")

#       assert show_live |> element("a", "Edit") |> render_click() =~
#                "Edit Customer"

#       assert_patch(show_live, ~p"/customers/#{customer}/show/edit")

#       assert show_live
#              |> form("#customer-form", customer: @invalid_attrs)
#              |> render_change() =~ "can&#39;t be blank"

#       assert show_live
#              |> form("#customer-form", customer: @update_attrs)
#              |> render_submit()

#       assert_patch(show_live, ~p"/customers/#{customer}")

#       html = render(show_live)
#       assert html =~ "Customer updated successfully"
#       assert html =~ "some updated email"
#     end
#   end
# end
