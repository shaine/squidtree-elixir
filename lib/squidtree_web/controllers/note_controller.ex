require Logger

defmodule SquidtreeWeb.NoteController do
  use SquidtreeWeb, :controller

  alias Squidtree.DocumentServer

  @notes_description "Shaine Hatch's Zettelkasten about engineering, leadership, and probably some other stuff."

  def index(conn, params) do
    with {:ok, recent_notes} <- DocumentServer.get_most_recent_notes(10, :modified_at),
         {:ok, note} <- DocumentServer.get_note("index") do
      render(
        conn,
        :index,
        assigns_from_content(note, %{
          recent_notes: recent_notes,
          page_description: @notes_description
        })
      )
    else
      _ ->
        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> render(:"500")
    end
  end

  def show(conn, %{"slug" => slug, "id" => id}) do
    show(conn, slug: slug, id: id)
  end

  def show(conn, %{"id" => id}) do
    show(conn, slug: nil, id: id)
  end

  def show(conn, slug: slug, id: id) do
    case DocumentServer.get_note(id) do
      {:ok, %{path: path} = note} ->
        if "/notes/#{slug}/#{id}" == path do
          conn
          |> render(:show, assigns_from_content(note))
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
