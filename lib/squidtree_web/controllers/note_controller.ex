require Logger

defmodule SquidtreeWeb.NoteController do
  use SquidtreeWeb, :controller

  alias Squidtree.Document

  def index(conn, params),
    do: show(conn, Map.merge(%{"id" => "index"}, params))

  def show(conn, params) do
    case params["id"]
         |> Document.get_content(
           post_directory: Path.join(:code.priv_dir(:squidtree), "note_contents/zk")
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

  defp assigns_from_content(content), do: Map.from_struct(content) |> Map.put(:layout_name, :note)
end
