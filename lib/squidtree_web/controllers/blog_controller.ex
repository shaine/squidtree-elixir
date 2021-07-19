require Logger

defmodule SquidtreeWeb.BlogController do
  use SquidtreeWeb, :controller

  alias Squidtree.DocumentServer

  @blog_description "The bloggy archives of Shaine Hatch."

  def index(conn, _params) do
    case DocumentServer.get_all_blog_posts() do
      {:ok, blog_posts} ->
        conn
        |> render(:index, %{
          title: "Blog",
          layout_name: :blog,
          base_path: "/blog/",
          page_description: @blog_description,
          blog_posts: blog_posts
        })

      {:error, message} ->
        Logger.warn(message)

        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render(:"500")
    end
  end

  def show(conn, %{"year" => year, "month" => month, "day" => day, "slug" => slug}) do
    show(conn, slug: slug, date_slug: "#{year}/#{month}/#{day}")
  end

  def show(conn, %{"slug" => slug}) do
    show(conn, slug: slug, date_slug: nil)
  end

  def show(conn, slug: slug, date_slug: date_slug) do
    case DocumentServer.get_blog(slug) do
      {:ok, %{path: path} = blog_post} ->
        if "/blog/#{date_slug}/#{slug}" == path do
          conn
          |> render(:show, assigns_from_content(blog_post))
        else
          conn
          |> put_status(301)
          |> redirect(to: path)
        end

      {:not_found} ->
        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render(:"404")

      {:error, message} ->
        Logger.warn(message)

        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render(:"500")
    end
  end

  defp assigns_from_content(content),
    do:
      Map.from_struct(content)
      |> Map.merge(%{
        layout_name: :blog,
        base_path: "/blog/",
        page_description: content.content_preview
      })
end
