defmodule Resolvd.ArticlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Articles` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        slug: "some slug",
        title: "some title"
      })
      |> Resolvd.Articles.create_category()

    category
  end

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        body: "some body",
        slug: "some slug",
        subject: "some subject"
      })
      |> Resolvd.Articles.create_article()

    article
  end
end
