require Logger

defmodule SquidtreeWeb.BlogController do
  use SquidtreeWeb, :controller

  alias Squidtree.Document

  def show(conn, params) do
    case params["slug"] |> Document.get_content() do
      {:ok, blog_post, _warnings, _raw_content} ->
        render(conn, "show.html", assigns_from_content(blog_post))

      {:error, blog_post, warnings, _raw_content} ->
        Enum.each(warnings, &Logger.warn/1)
        render(conn, "show.html", assigns_from_content(blog_post))

      {:error, message} ->
        Logger.warn(message)
        render(conn, SquidtreeWeb.ErrorView, "500.html")
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
