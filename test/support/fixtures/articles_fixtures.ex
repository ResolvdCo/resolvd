defmodule Resolvd.ArticlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Articles` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(user, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        slug: "some slug",
        title: "some title"
      })

    {:ok, category} = Resolvd.Articles.create_category(user, attrs)

    category
  end

  @doc """
  Generate a article.
  """
  def article_fixture(user, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        body: "some body",
        slug: "some slug",
        subject: "some subject"
      })

    {:ok, article} = Resolvd.Articles.create_article(user, attrs)

    article
  end
end
