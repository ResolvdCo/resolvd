defmodule Resolvd.TenantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Tenants` context.
  """

  @doc """
  Generate a tenant_mail_config.
  """
  def tenant_mail_config_fixture(attrs \\ %{}) do
    {:ok, tenant_mail_config} =
      attrs
      |> Enum.into(%{
        adapter: "some adapter",
        config: %{},
        direction: "some direction"
      })
      |> Resolvd.Tenants.create_tenant_mail_config()

    tenant_mail_config
  end

  @doc """
  Generate a tenant_inbound_mail_config.
  """
  def tenant_inbound_mail_config_fixture(attrs \\ %{}) do
    {:ok, tenant_inbound_mail_config} =
      attrs
      |> Enum.into(%{
        mailbox: "some mailbox",
        mark_when_read: true,
        password: "some password",
        port: 42,
        server: "some server",
        tls: true,
        type: "some type",
        username: "some username"
      })
      |> Resolvd.Tenants.create_tenant_inbound_mail_config()

    tenant_inbound_mail_config
  end

  @doc """
  Generate a mail_server.
  """
  def mail_server_fixture(attrs \\ %{}) do
    {:ok, mail_server} =
      attrs
      |> Enum.into(%{
        inbound_config: %{},
        inbound_type: "some inbound_type",
        outbound_config: %{},
        outbound_type: "some outbound_type"
      })
      |> Resolvd.Tenants.create_mail_server()

    mail_server
  end
end
