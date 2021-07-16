defmodule SquidtreeWeb.PageController do
  require Logger

  use SquidtreeWeb, :controller

  alias SquidtreeWeb.Router.Helpers
  alias Squidtree.DocumentServer

  @home_description "A place for Shaine Hatch to store his words."
  @about_description "Squidtree is a place for Shaine Hatch to keep his words, in the form of Zettelkasten notes and blog content."
  @sitemap_description "Sitemap"

  def index(conn, _params) do
    with {:ok, recent_notes} <- DocumentServer.get_most_recent_notes(3),
         {:ok, recent_blog_posts} <- DocumentServer.get_most_recent_blog_posts(3) do
      render(conn, :home, %{
        page_description: @home_description,
        layout_name: :home,
        recent_notes: recent_notes,
        recent_blog_posts: recent_blog_posts
      })
    end
  end

  def about(conn, _params) do
    render(conn, :about, %{
      page_description: @home_description,
      layout_name: :page
    })
  end

  def sitemap(conn, format: format) do
    with {:ok, blog_posts} <- DocumentServer.get_all_blog_posts,
         {:ok, references} <- DocumentServer.get_all_references,
         {:ok, notes} <- DocumentServer.get_all_notes do
      conn
      |> put_view(SquidtreeWeb.SitemapView)
      |> render("sitemap.#{format}", %{
        blog_posts: blog_posts,
        references: references,
        notes: notes,
        page_description: @sitemap_description,
        layout_name: :page
      })
    else
      err ->
        Logger.warning(err)
        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render(:"500")
    end
  end

  def sitemap(conn, %{"format" => "xml"}), do: sitemap(conn, format: :xml)

  def sitemap(conn, %{"format" => _}),
    do:
      conn
      |> put_view(SquidtreeWeb.ErrorView)
      |> render(:"404")

  def sitemap(conn, params) do
    sitemap(conn, format: :html)
  end
end
