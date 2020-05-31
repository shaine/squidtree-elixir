require Logger

defmodule SquidtreeWeb.BlogController do
  use SquidtreeWeb, :controller

  alias Squidtree.BlogPost

  def show(conn, params) do
    case params["slug"] |> BlogPost.get_blog_post() do
      {:ok, blog_post, _} ->
        render(conn, "show.html", Map.from_struct(blog_post))

      {:error, blog_post, warnings} ->
        Enum.each(warnings, &Logger.warn/1)
        render(conn, "show.html", Map.from_struct(blog_post))

      {:error, _message} ->
        render(conn, SquidtreeWeb.ErrorView, "500.html")
    end
  end
end
