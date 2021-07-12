require Logger

defmodule SquidtreeWeb.NoteController do
  use SquidtreeWeb, :controller

  alias Squidtree.DocumentServer

  def index(conn, params) do
    with {:ok, recent_notes} <- DocumentServer.get_most_recent_notes(10),
         {:ok, recent_references} <- DocumentServer.get_most_recent_references(5),
         {:ok, note} <- DocumentServer.get_note("index") do
      render(
        conn,
        "index.html",
        assigns_from_content(note, %{
          recent_notes: recent_notes,
          recent_references: recent_references
        })
      )
    else
      _ ->
        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render("500.html")
    end
  end

  def show(conn, params) do
    case params["id"] |> DocumentServer.get_note() do
      {:ok, note} ->
        render(conn, "show.html", assigns_from_content(note))

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

  defp assigns_from_content(content, attrs \\ %{}),
    do:
      Map.from_struct(content)
      |> Map.merge(%{
        layout_name: :note,
        base_path: "/notes/",
        page_description: content.content_preview
      })
      |> Map.merge(attrs)
end
