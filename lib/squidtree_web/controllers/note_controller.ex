require Logger

defmodule SquidtreeWeb.NoteController do
  use SquidtreeWeb, :controller

  alias Squidtree.Document

  def index(conn, params),
    do: show(conn, Map.put(params, "id", "index"))

  def show(conn, params) do
    case params["id"]
         |> Document.get_content(
           post_directory: Path.join(:code.priv_dir(:squidtree), "note_contents")
         ) do
      {:ok, note, _} ->
        render(conn, "show.html", assigns_from_content(note))

      {:error, note, warnings} ->
        Enum.each(warnings, &Logger.warn/1)
        render(conn, "show.html", assigns_from_content(note))

      {:error, message} ->
        Logger.warn(message)
        render(conn, SquidtreeWeb.ErrorView, "500.html")
    end
  end

  defp assigns_from_content(content),
    do: Map.from_struct(content) |> Map.merge(%{layout_name: :note, base_path: "/notes/"})
end
