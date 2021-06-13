require Logger

defmodule SquidtreeWeb.BlogController do
  use SquidtreeWeb, :controller

  alias Squidtree.Document

  def show(conn, params) do
    case params["slug"] |> Document.get_content() do
      {:ok, blog_post, _} ->
        render(conn, "show.html", assigns_from_content(blog_post))

      {:error, blog_post, warnings} ->
        Enum.each(warnings, &Logger.warn/1)
        render(conn, "show.html", assigns_from_content(blog_post))

      {:error, _message} ->
        render(conn, SquidtreeWeb.ErrorView, "500.html")
    end
  end

  defp assigns_from_content(content), do: Map.from_struct(content) |> Map.put(:layout_name, :blog)
end
