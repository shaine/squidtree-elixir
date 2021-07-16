require Logger

defmodule SquidtreeWeb.BlogController do
  use SquidtreeWeb, :controller

  alias Squidtree.DocumentServer

  @blog_description "The bloggy archives of Shaine Hatch."

  def index(conn, _params) do
    case DocumentServer.get_all_blog_posts() do
      {:ok, blog_posts} ->
        render(conn, "index.html", %{
          layout_name: :blog,
          base_path: "/blog/",
          page_description: @blog_description,
          blog_posts: blog_posts
        })

      {:error, message} ->
        Logger.warn(message)

        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render("500.html")
    end
  end

  def show(conn, params) do
    case params["slug"] |> DocumentServer.get_blog() do
      {:ok, blog_post} ->
        render(conn, "show.html", assigns_from_content(blog_post))

      {:not_found} ->
        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render("404.html")

      {:error, message} ->
        Logger.warn(message)

        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render("500.html")
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
