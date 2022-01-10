require Logger

defmodule SquidtreeWeb.NoteController do
  use SquidtreeWeb, :controller

  alias Squidtree.DocumentServer

  def index(conn, params) do
    with {:ok, recent_notes} <- DocumentServer.get_most_recent_notes(10, :modified_at),
         {:ok, note} <- DocumentServer.get_note("index") do
      render(
        conn,
        :index,
        assigns_from_content(note, %{
          title: "Notes index",
          recent_notes: recent_notes,
          page_description: "Shaine Hatch's Zettelkasten about engineering, leadership, and probably some other stuff."
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
      {:ok, %{path: path, redirect: redirect} = note} ->
        cond do
          redirect ->
            conn
            |> put_status(301)
            |> redirect(to: "/notes/#{redirect}")
          "/notes/#{slug}/#{id}" != path ->
            conn
            |> put_status(301)
            |> redirect(to: path)
          true ->
            conn
            |> render(:show, assigns_from_content(note))
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
