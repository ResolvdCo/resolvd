defmodule Resolvd.TenantsTest do
  use Resolvd.DataCase

  alias Resolvd.Tenants

  describe "tenant_mail_configs" do
    alias Resolvd.Tenants.TenantMailConfig

    import Resolvd.TenantsFixtures

    @invalid_attrs %{adapter: nil, config: nil, direction: nil}

    test "list_tenant_mail_configs/0 returns all tenant_mail_configs" do
      tenant_mail_config = tenant_mail_config_fixture()
      assert Tenants.list_tenant_mail_configs() == [tenant_mail_config]
    end

    test "get_tenant_mail_config!/1 returns the tenant_mail_config with given id" do
      tenant_mail_config = tenant_mail_config_fixture()
      assert Tenants.get_tenant_mail_config!(tenant_mail_config.id) == tenant_mail_config
    end

    test "create_tenant_mail_config/1 with valid data creates a tenant_mail_config" do
      valid_attrs = %{adapter: "some adapter", config: %{}, direction: "some direction"}

      assert {:ok, %TenantMailConfig{} = tenant_mail_config} = Tenants.create_tenant_mail_config(valid_attrs)
      assert tenant_mail_config.adapter == "some adapter"
      assert tenant_mail_config.config == %{}
      assert tenant_mail_config.direction == "some direction"
    end

    test "create_tenant_mail_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tenants.create_tenant_mail_config(@invalid_attrs)
    end

    test "update_tenant_mail_config/2 with valid data updates the tenant_mail_config" do
      tenant_mail_config = tenant_mail_config_fixture()
      update_attrs = %{adapter: "some updated adapter", config: %{}, direction: "some updated direction"}

      assert {:ok, %TenantMailConfig{} = tenant_mail_config} = Tenants.update_tenant_mail_config(tenant_mail_config, update_attrs)
      assert tenant_mail_config.adapter == "some updated adapter"
      assert tenant_mail_config.config == %{}
      assert tenant_mail_config.direction == "some updated direction"
    end

    test "update_tenant_mail_config/2 with invalid data returns error changeset" do
      tenant_mail_config = tenant_mail_config_fixture()
      assert {:error, %Ecto.Changeset{}} = Tenants.update_tenant_mail_config(tenant_mail_config, @invalid_attrs)
      assert tenant_mail_config == Tenants.get_tenant_mail_config!(tenant_mail_config.id)
    end

    test "delete_tenant_mail_config/1 deletes the tenant_mail_config" do
      tenant_mail_config = tenant_mail_config_fixture()
      assert {:ok, %TenantMailConfig{}} = Tenants.delete_tenant_mail_config(tenant_mail_config)
      assert_raise Ecto.NoResultsError, fn -> Tenants.get_tenant_mail_config!(tenant_mail_config.id) end
    end

    test "change_tenant_mail_config/1 returns a tenant_mail_config changeset" do
      tenant_mail_config = tenant_mail_config_fixture()
      assert %Ecto.Changeset{} = Tenants.change_tenant_mail_config(tenant_mail_config)
    end
  end

  describe "tenant_inbound_mail_configs" do
    alias Resolvd.Tenants.TenantInboundMailConfig

    import Resolvd.TenantsFixtures

    @invalid_attrs %{mailbox: nil, mark_when_read: nil, password: nil, port: nil, server: nil, tls: nil, type: nil, username: nil}

    test "list_tenant_inbound_mail_configs/0 returns all tenant_inbound_mail_configs" do
      tenant_inbound_mail_config = tenant_inbound_mail_config_fixture()
      assert Tenants.list_tenant_inbound_mail_configs() == [tenant_inbound_mail_config]
    end

    test "get_tenant_inbound_mail_config!/1 returns the tenant_inbound_mail_config with given id" do
      tenant_inbound_mail_config = tenant_inbound_mail_config_fixture()
      assert Tenants.get_tenant_inbound_mail_config!(tenant_inbound_mail_config.id) == tenant_inbound_mail_config
    end

    test "create_tenant_inbound_mail_config/1 with valid data creates a tenant_inbound_mail_config" do
      valid_attrs = %{mailbox: "some mailbox", mark_when_read: true, password: "some password", port: 42, server: "some server", tls: true, type: "some type", username: "some username"}

      assert {:ok, %TenantInboundMailConfig{} = tenant_inbound_mail_config} = Tenants.create_tenant_inbound_mail_config(valid_attrs)
      assert tenant_inbound_mail_config.mailbox == "some mailbox"
      assert tenant_inbound_mail_config.mark_when_read == true
      assert tenant_inbound_mail_config.password == "some password"
      assert tenant_inbound_mail_config.port == 42
      assert tenant_inbound_mail_config.server == "some server"
      assert tenant_inbound_mail_config.tls == true
      assert tenant_inbound_mail_config.type == "some type"
      assert tenant_inbound_mail_config.username == "some username"
    end

    test "create_tenant_inbound_mail_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tenants.create_tenant_inbound_mail_config(@invalid_attrs)
    end

    test "update_tenant_inbound_mail_config/2 with valid data updates the tenant_inbound_mail_config" do
      tenant_inbound_mail_config = tenant_inbound_mail_config_fixture()
      update_attrs = %{mailbox: "some updated mailbox", mark_when_read: false, password: "some updated password", port: 43, server: "some updated server", tls: false, type: "some updated type", username: "some updated username"}

      assert {:ok, %TenantInboundMailConfig{} = tenant_inbound_mail_config} = Tenants.update_tenant_inbound_mail_config(tenant_inbound_mail_config, update_attrs)
      assert tenant_inbound_mail_config.mailbox == "some updated mailbox"
      assert tenant_inbound_mail_config.mark_when_read == false
      assert tenant_inbound_mail_config.password == "some updated password"
      assert tenant_inbound_mail_config.port == 43
      assert tenant_inbound_mail_config.server == "some updated server"
      assert tenant_inbound_mail_config.tls == false
      assert tenant_inbound_mail_config.type == "some updated type"
      assert tenant_inbound_mail_config.username == "some updated username"
    end

    test "update_tenant_inbound_mail_config/2 with invalid data returns error changeset" do
      tenant_inbound_mail_config = tenant_inbound_mail_config_fixture()
      assert {:error, %Ecto.Changeset{}} = Tenants.update_tenant_inbound_mail_config(tenant_inbound_mail_config, @invalid_attrs)
      assert tenant_inbound_mail_config == Tenants.get_tenant_inbound_mail_config!(tenant_inbound_mail_config.id)
    end

    test "delete_tenant_inbound_mail_config/1 deletes the tenant_inbound_mail_config" do
      tenant_inbound_mail_config = tenant_inbound_mail_config_fixture()
      assert {:ok, %TenantInboundMailConfig{}} = Tenants.delete_tenant_inbound_mail_config(tenant_inbound_mail_config)
      assert_raise Ecto.NoResultsError, fn -> Tenants.get_tenant_inbound_mail_config!(tenant_inbound_mail_config.id) end
    end

    test "change_tenant_inbound_mail_config/1 returns a tenant_inbound_mail_config changeset" do
      tenant_inbound_mail_config = tenant_inbound_mail_config_fixture()
      assert %Ecto.Changeset{} = Tenants.change_tenant_inbound_mail_config(tenant_inbound_mail_config)
    end
  end

  describe "mail_servers" do
    alias Resolvd.Tenants.MailServer

    import Resolvd.TenantsFixtures

    @invalid_attrs %{inbound_config: nil, inbound_type: nil, outbound_config: nil, outbound_type: nil}

    test "list_mail_servers/0 returns all mail_servers" do
      mail_server = mail_server_fixture()
      assert Tenants.list_mail_servers() == [mail_server]
    end

    test "get_mail_server!/1 returns the mail_server with given id" do
      mail_server = mail_server_fixture()
      assert Tenants.get_mail_server!(mail_server.id) == mail_server
    end

    test "create_mail_server/1 with valid data creates a mail_server" do
      valid_attrs = %{inbound_config: %{}, inbound_type: "some inbound_type", outbound_config: %{}, outbound_type: "some outbound_type"}

      assert {:ok, %MailServer{} = mail_server} = Tenants.create_mail_server(valid_attrs)
      assert mail_server.inbound_config == %{}
      assert mail_server.inbound_type == "some inbound_type"
      assert mail_server.outbound_config == %{}
      assert mail_server.outbound_type == "some outbound_type"
    end

    test "create_mail_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tenants.create_mail_server(@invalid_attrs)
    end

    test "update_mail_server/2 with valid data updates the mail_server" do
      mail_server = mail_server_fixture()
      update_attrs = %{inbound_config: %{}, inbound_type: "some updated inbound_type", outbound_config: %{}, outbound_type: "some updated outbound_type"}

      assert {:ok, %MailServer{} = mail_server} = Tenants.update_mail_server(mail_server, update_attrs)
      assert mail_server.inbound_config == %{}
      assert mail_server.inbound_type == "some updated inbound_type"
      assert mail_server.outbound_config == %{}
      assert mail_server.outbound_type == "some updated outbound_type"
    end

    test "update_mail_server/2 with invalid data returns error changeset" do
      mail_server = mail_server_fixture()
      assert {:error, %Ecto.Changeset{}} = Tenants.update_mail_server(mail_server, @invalid_attrs)
      assert mail_server == Tenants.get_mail_server!(mail_server.id)
    end

    test "delete_mail_server/1 deletes the mail_server" do
      mail_server = mail_server_fixture()
      assert {:ok, %MailServer{}} = Tenants.delete_mail_server(mail_server)
      assert_raise Ecto.NoResultsError, fn -> Tenants.get_mail_server!(mail_server.id) end
    end

    test "change_mail_server/1 returns a mail_server changeset" do
      mail_server = mail_server_fixture()
      assert %Ecto.Changeset{} = Tenants.change_mail_server(mail_server)
    end
  end
end
