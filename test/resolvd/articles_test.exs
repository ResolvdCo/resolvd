defmodule Resolvd.ArticlesTest do
  use Resolvd.DataCase

  alias Resolvd.Articles

  describe "categories" do
    alias Resolvd.Articles.Category

    import Resolvd.ArticlesFixtures

    @invalid_attrs %{slug: nil, title: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Articles.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Articles.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{slug: "some slug", title: "some title"}

      assert {:ok, %Category{} = category} = Articles.create_category(valid_attrs)
      assert category.slug == "some slug"
      assert category.title == "some title"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Articles.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{slug: "some updated slug", title: "some updated title"}

      assert {:ok, %Category{} = category} = Articles.update_category(category, update_attrs)
      assert category.slug == "some updated slug"
      assert category.title == "some updated title"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Articles.update_category(category, @invalid_attrs)
      assert category == Articles.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Articles.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Articles.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Articles.change_category(category)
    end
  end

  describe "articles" do
    alias Resolvd.Articles.Article

    import Resolvd.ArticlesFixtures

    @invalid_attrs %{body: nil, subject: nil}

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Articles.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Articles.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      valid_attrs = %{body: "some body", subject: "some subject"}

      assert {:ok, %Article{} = article} = Articles.create_article(valid_attrs)
      assert article.body == "some body"
      assert article.slug == "some-subject"
      assert article.subject == "some subject"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Articles.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()

      update_attrs = %{
        body: "some updated body",
        slug: "some-updated-slug",
        subject: "some updated subject"
      }

      assert {:ok, %Article{} = article} = Articles.update_article(article, update_attrs)
      assert article.body == "some updated body"
      assert article.slug == "some-updated-subject"
      assert article.subject == "some updated subject"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Articles.update_article(article, @invalid_attrs)
      assert article == Articles.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Articles.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Articles.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Articles.change_article(article)
    end
  end
end
