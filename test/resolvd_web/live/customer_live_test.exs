defmodule ResolvdWeb.CustomerLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.CustomersFixtures, only: [customer_fixture: 1]
  import Resolvd.AccountsFixtures, only: [user_fixture: 1]
  import Resolvd.MailboxesFixtures, only: [mailbox_fixture: 1]
  import Resolvd.ConversationsFixtures, only: [conversation_fixture: 3]

  # @create_attrs %{email: "some email", name: "some name", phone: "some phone"}
  # @update_attrs %{
  #   email: "some updated email",
  #   name: "some updated name",
  #   phone: "some updated phone"
  # }
  # @invalid_attrs %{email: nil, name: nil, phone: nil}

  defp create_customers(%{tenant: tenant} = other) do
    customers = for _ <- 1..5, do: customer_fixture(tenant)
    Map.put(other, :customers, customers)
  end

  defp create_mailboxes(%{admin: admin} = other) do
    mailboxes = for _ <- 1..5, do: mailbox_fixture(admin)
    Map.put(other, :mailboxes, mailboxes)
  end

  defp create_users(%{admin: admin} = other) do
    users = for _ <- 1..5, do: user_fixture(admin)
    Map.put(other, :users, users)
  end

  defp create_conversations(%{user: user, customers: customers, mailboxes: [mailbox | _]} = other) do
    conversations =
      Enum.flat_map(customers, fn customer ->
        for _ <- 1..5, do: conversation_fixture(user, customer, mailbox)
      end)

    Map.put(other, :conversations, conversations)
  end

  describe "Index" do
    setup [:create_tenant_and_admin, :log_in_admin, :create_customers]

    test "redirect to first customer", %{conn: conn, customers: customers} do
      assert {:error, {:live_redirect, %{to: "/customers?id=" <> id = customer_path}}} =
               live(conn, ~p"/customers")

      customer = Enum.find(customers, fn customer -> customer.id == id end)

      assert {:ok, view, html} = live(conn, customer_path)
      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      assert html =~ "Customers"

      Enum.each(customers, fn customer ->
        assert html =~ customer.name
        assert html =~ customer.email
      end)
    end

    test "switch customer", %{conn: conn, customers: [customer1, customer2 | _]} do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer1.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer1.name
      assert page_title(view) =~ customer1.name

      assert view |> element("#customers-#{customer2.id}") |> render_click() =~
               customer2.phone

      assert_patched(view, ~p"/customers?id=#{customer2.id}")

      assert view |> element("#customer-name-title") |> render() =~ customer2.name
      assert page_title(view) =~ customer2.name
    end

    # test "saves new customer", %{conn: conn} do
    #   {:ok, index_live, _html} = live(conn, ~p"/customers")

    #   assert index_live |> element("a", "New Customer") |> render_click() =~
    #            "New Customer"

    #   assert_patch(index_live, ~p"/customers/new")

    #   assert index_live
    #          |> form("#customer-form", customer: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   assert index_live
    #          |> form("#customer-form", customer: @create_attrs)
    #          |> render_submit()

    #   assert_patch(index_live, ~p"/customers")

    #   html = render(index_live)
    #   assert html =~ "Customer created successfully"
    #   assert html =~ "some email"
    # end

    # test "updates customer in listing", %{conn: conn, customer: customer} do
    #   {:ok, index_live, _html} = live(conn, ~p"/customers")

    #   assert index_live |> element("#customers-#{customer.id} a", "Edit") |> render_click() =~
    #            "Edit Customer"

    #   assert_patch(index_live, ~p"/customers/#{customer}/edit")

    #   assert index_live
    #          |> form("#customer-form", customer: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   assert index_live
    #          |> form("#customer-form", customer: @update_attrs)
    #          |> render_submit()

    #   assert_patch(index_live, ~p"/customers")

    #   html = render(index_live)
    #   assert html =~ "Customer updated successfully"
    #   assert html =~ "some updated email"
    # end

    # test "deletes customer in listing", %{conn: conn, customer: customer} do
    #   {:ok, index_live, _html} = live(conn, ~p"/customers")

    #   assert index_live |> element("#customers-#{customer.id} a", "Delete") |> render_click()
    #   refute has_element?(index_live, "#customers-#{customer.id}")
    # end
  end

  describe "Customer conversations" do
    setup [
      :create_tenant_and_admin,
      :create_users,
      :log_in_admin,
      :create_customers,
      :create_mailboxes,
      :create_conversations
    ]

    test "list all conversations for customer", %{
      conn: conn,
      customers: [customer | _],
      conversations: conversations
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      assert conversations
             |> Enum.filter(fn convo -> convo.customer_id == customer.id end)
             |> Enum.map(fn convo ->
               assert view |> element("#conversations-#{convo.id}") |> render =~ convo.subject
             end)
             |> Enum.count() == 5
    end

    test "switching displays conversations for selected customer", %{
      conn: conn,
      customers: [customer1, customer2 | _],
      conversations: conversations
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer1.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer1.name
      assert page_title(view) =~ customer1.name

      assert conversations
             |> Enum.filter(fn convo -> convo.customer_id == customer1.id end)
             |> Enum.map(fn convo ->
               assert view |> element("#conversations-#{convo.id}") |> render =~ convo.subject
             end)
             |> Enum.count() == 5

      assert view |> element("#customers-#{customer2.id}") |> render_click() =~
               customer2.phone

      assert_patched(view, ~p"/customers?id=#{customer2.id}")

      assert view |> element("#customer-name-title") |> render() =~ customer2.name
      assert page_title(view) =~ customer2.name

      assert conversations
             |> Enum.filter(fn convo -> convo.customer_id == customer2.id end)
             |> Enum.map(fn convo ->
               assert view |> element("#conversations-#{convo.id}") |> render =~ convo.subject
             end)
             |> Enum.count() == 5
    end

    test "clicking on conversation opens modal", %{
      conn: conn,
      customers: [customer | _],
      conversations: conversations
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      assert conversations
             |> Enum.filter(fn convo -> convo.customer_id == customer.id end)
             |> Enum.map(fn convo ->
               assert view |> element("#conversations-#{convo.id}") |> render =~ convo.subject
             end)
             |> Enum.count() == 5

      conversation =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)
        |> Enum.random()

      view
      |> element("#conversations-#{conversation.id} > :first-child > :first-child")
      |> render_click

      assert_patched(view, ~p"/customers?id=#{customer.id}&conversation_id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject
    end

    test "switch to another conversation", %{
      conn: conn,
      customers: [customer | _],
      conversations: conversations
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      assert conversations
             |> Enum.filter(fn convo -> convo.customer_id == customer.id end)
             |> Enum.map(fn convo ->
               assert view |> element("#conversations-#{convo.id}") |> render =~ convo.subject
             end)
             |> Enum.count() == 5

      [conversation1, conversation2 | _] =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)

      view
      |> element("#conversations-#{conversation1.id} > :first-child > :first-child")
      |> render_click

      assert_patched(view, ~p"/customers?id=#{customer.id}&conversation_id=#{conversation1.id}")
      assert page_title(view) =~ conversation1.subject

      assert {:ok, view, _html} =
               live(conn, ~p"/customers?id=#{customer.id}&conversation_id=#{conversation2.id}")

      assert page_title(view) =~ conversation2.subject
    end
  end

  describe "Customer conversations user/mailbox assignment" do
    setup [
      :create_tenant_and_admin,
      :create_users,
      :log_in_admin,
      :create_customers,
      :create_mailboxes,
      :create_conversations
    ]

    test "assign to user", %{
      conn: conn,
      customers: [customer | _],
      conversations: conversations,
      users: [user | _]
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      conversation =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)
        |> Enum.random()

      view
      |> element("#assignee-select-#{conversation.id}")
      |> render_change(%{
        "assignee-#{conversation.id}" => user.id,
        _target: "assignee-#{conversation.id}"
      })

      assert view |> element("#assigned-#{conversation.id}") |> render() =~ user.id
    end

    test "unassign user", %{
      conn: conn,
      customers: [customer | _],
      conversations: conversations,
      users: [user | _]
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      conversation =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)
        |> Enum.random()

      view
      |> element("#assignee-select-#{conversation.id}")
      |> render_change(%{
        "assignee-#{conversation.id}" => user.id,
        _target: "assignee-#{conversation.id}"
      })

      assert view |> element("#assigned-#{conversation.id}") |> render() =~ user.id

      view
      |> element("#assignee-select-#{conversation.id}")
      |> render_change(%{
        "assignee-#{conversation.id}" => "",
        _target: "assignee-#{conversation.id}"
      })

      assert view |> element("#assigned-#{conversation.id}") |> render() =~ "Not assigned"
    end

    test "reassign user", %{
      conn: conn,
      customers: [customer | _],
      conversations: conversations,
      users: [user1, user2 | _]
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      conversation =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)
        |> Enum.random()

      view
      |> element("#assignee-select-#{conversation.id}")
      |> render_change(%{
        "assignee-#{conversation.id}" => user1.id,
        _target: "assignee-#{conversation.id}"
      })

      assert view |> element("#assigned-#{conversation.id}") |> render() =~ user1.id

      view
      |> element("#assignee-select-#{conversation.id}")
      |> render_change(%{
        "assignee-#{conversation.id}" => user2.id,
        _target: "assignee-#{conversation.id}"
      })

      assert view |> element("#assigned-#{conversation.id}") |> render() =~ user2.id
    end

    test "assign mailbox", %{
      conn: conn,
      customers: [customer | _],
      conversations: conversations,
      mailboxes: [mailbox | _]
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      conversation =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)
        |> Enum.random()

      view
      |> element("#mailbox-select-#{conversation.id}")
      |> render_change(%{
        "mailbox-#{conversation.id}" => mailbox.id,
        _target: "mailbox-#{conversation.id}"
      })

      assert view |> element("#mailbox-#{conversation.id}") |> render() =~ mailbox.id
    end

    test "reassign mailbox", %{
      conn: conn,
      customers: [customer | _],
      conversations: conversations,
      mailboxes: [mb1, mb2 | _]
    } do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      conversation =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)
        |> Enum.random()

      view
      |> element("#mailbox-select-#{conversation.id}")
      |> render_change(%{
        "mailbox-#{conversation.id}" => mb1.id,
        _target: "mailbox-#{conversation.id}"
      })

      assert view |> element("#mailbox-#{conversation.id}") |> render() =~ mb1.id

      view
      |> element("#mailbox-select-#{conversation.id}")
      |> render_change(%{
        "mailbox-#{conversation.id}" => mb2.id,
        _target: "mailbox-#{conversation.id}"
      })

      assert view |> element("#mailbox-#{conversation.id}") |> render() =~ mb2.id
    end
  end

  describe "Customer conversations status" do
    setup [
      :create_tenant_and_admin,
      :create_users,
      :log_in_admin,
      :create_customers,
      :create_mailboxes,
      :create_conversations
    ]

    test "toggle priority", %{conn: conn, customers: [customer | _], conversations: conversations} do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      conversation =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)
        |> Enum.random()

      view
      |> element("#priority-change-#{conversation.id}")
      |> render_change(%{
        "priority-#{conversation.id}" => true,
        _target: "priority-#{conversation.id}"
      })

      assert view |> element("#status-#{conversation.id}") |> render() =~ "Prioritized"

      view
      |> element("#priority-change-#{conversation.id}")
      |> render_change(%{
        "priority-#{conversation.id}" => false,
        _target: "priority-#{conversation.id}"
      })

      assert view |> element("#status-#{conversation.id}") |> render() =~ "Unresolved"
    end

    test "toggle resolved", %{conn: conn, customers: [customer | _], conversations: conversations} do
      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      assert view |> element("#customer-name-title") |> render() =~ customer.name
      assert page_title(view) =~ customer.name

      conversation =
        Enum.filter(conversations, fn convo -> convo.customer_id == customer.id end)
        |> Enum.random()

      view
      |> element("#resolved-change-#{conversation.id}")
      |> render_change(%{
        "resolved-#{conversation.id}" => true,
        _target: "resolved-#{conversation.id}"
      })

      assert view |> element("#status-#{conversation.id}") |> render() =~ "Resolved"

      view
      |> element("#resolved-change-#{conversation.id}")
      |> render_change(%{
        "resolved-#{conversation.id}" => false,
        _target: "resolved-#{conversation.id}"
      })

      assert view |> element("#status-#{conversation.id}") |> render() =~ "Unresolved"
    end
  end

  describe "Search customers" do
    setup [
      :create_tenant_and_admin,
      :log_in_admin,
      :create_customers,
      :create_mailboxes,
      :create_conversations
    ]

    test "by name", %{conn: conn, customers: customers} do
      [customer | others] = Enum.shuffle(customers)

      assert {:ok, view, html} = live(conn, ~p"/customers?id=#{customer.id}")
      assert html =~ "Customers"

      customers_view = view |> element("#customers") |> render()

      Enum.each(customers, fn customer ->
        assert customers_view =~ customer.name
        assert customers_view =~ customer.email
        assert customers_view =~ "customers-#{customer.id}"
      end)

      view |> element("#customer-search") |> render_change(%{query: customer.name})
      customers_view = view |> element("#customers") |> render()

      assert customers_view =~ customer.name
      assert customers_view =~ customer.email
      assert customers_view =~ "customers-#{customer.id}"

      Enum.each(others, fn customer ->
        refute customers_view =~ customer.name
        refute customers_view =~ customer.email
        refute customers_view =~ "customers-#{customer.id}"
      end)
    end

    test "by email", %{conn: conn, customers: customers} do
      [customer | others] = Enum.shuffle(customers)

      assert {:ok, view, _html} = live(conn, ~p"/customers?id=#{customer.id}")

      view |> element("#customer-search") |> render_change(%{query: customer.email})
      customers_view = view |> element("#customers") |> render()

      assert customers_view =~ customer.name
      assert customers_view =~ customer.email
      assert customers_view =~ "customers-#{customer.id}"

      Enum.each(others, fn customer ->
        refute customers_view =~ customer.name
        refute customers_view =~ customer.email
        refute customers_view =~ "customers-#{customer.id}"
      end)
    end

    test "by phone", %{conn: conn, customers: customers} do
      [customer | others] = Enum.shuffle(customers)

      assert {:ok, view, _html} = live(conn, ~p"/customers?id=#{customer.id}")

      view |> element("#customer-search") |> render_change(%{query: customer.phone})
      customers_view = view |> element("#customers") |> render()

      assert customers_view =~ customer.name
      assert customers_view =~ customer.email
      assert customers_view =~ "customers-#{customer.id}"

      Enum.each(others, fn customer ->
        refute customers_view =~ customer.name
        refute customers_view =~ customer.email
        refute customers_view =~ "customers-#{customer.id}"
      end)
    end

    test "when no match", %{conn: conn, customers: customers} do
      [customer | _] = Enum.shuffle(customers)

      assert {:ok, view, _html} = live(conn, ~p"/customers?id=#{customer.id}")

      view |> element("#customer-search") |> render_change(%{query: "abracadabra"})
      customers_view = view |> element("#customers") |> render()

      Enum.each(customers, fn customer ->
        refute customers_view =~ customer.name
        refute customers_view =~ customer.email
        refute customers_view =~ "customers-#{customer.id}"
      end)
    end

    test "clear query", %{conn: conn, customers: customers} do
      [customer | others] = Enum.shuffle(customers)

      assert {:ok, view, _html} = live(conn, ~p"/customers?id=#{customer.id}")

      view |> element("#customer-search") |> render_change(%{query: customer.name})
      customers_view = view |> element("#customers") |> render()

      assert customers_view =~ customer.name
      assert customers_view =~ customer.email
      assert customers_view =~ "customers-#{customer.id}"

      Enum.each(others, fn customer ->
        refute customers_view =~ customer.name
        refute customers_view =~ customer.email
        refute customers_view =~ "customers-#{customer.id}"
      end)

      view |> element("#customer-search") |> render_change(%{query: ""})
      customers_view = view |> element("#customers") |> render()

      Enum.each(customers, fn customer ->
        assert customers_view =~ customer.name
        assert customers_view =~ customer.email
        assert customers_view =~ "customers-#{customer.id}"
      end)
    end
  end

  # describe "Show" do
  #   setup [:create_customer]

  #   test "displays customer", %{conn: conn, customer: customer} do
  #     {:ok, _show_live, html} = live(conn, ~p"/customers/#{customer}")

  #     assert html =~ "Show Customer"
  #     assert html =~ customer.email
  #   end

  #   test "updates customer within modal", %{conn: conn, customer: customer} do
  #     {:ok, show_live, _html} = live(conn, ~p"/customers/#{customer}")

  #     assert show_live |> element("a", "Edit") |> render_click() =~
  #              "Edit Customer"

  #     assert_patch(show_live, ~p"/customers/#{customer}/show/edit")

  #     assert show_live
  #            |> form("#customer-form", customer: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert show_live
  #            |> form("#customer-form", customer: @update_attrs)
  #            |> render_submit()

  #     assert_patch(show_live, ~p"/customers/#{customer}")

  #     html = render(show_live)
  #     assert html =~ "Customer updated successfully"
  #     assert html =~ "some updated email"
  #   end
  # end
end
