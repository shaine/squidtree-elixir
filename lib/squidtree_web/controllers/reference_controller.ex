require Logger

defmodule SquidtreeWeb.ReferenceController do
  use SquidtreeWeb, :controller

  alias Squidtree.{Document, DocumentServer}

  def index(conn, _params) do
    with {:ok, references} <- DocumentServer.get_all_references() do
      render(conn, :index, %{
        title: "References",
        references: references,
        year: 0,
        month: 0,
        layout_name: :reference,
        base_path: "/references/",
        page_description: ""
      })
    end
  end

  def show(conn, params) do
    with slug <- params["slug"],
         {:ok, notes} <- DocumentServer.find_all_by_reference(slug),
         {:ok, reference} <- DocumentServer.get_reference(slug) do
      render(conn, :show, assigns_from_content(reference, notes))
    else
      {:not_found} ->
        missing_reference(conn, params)

      {:error, message} ->
        Logger.warn(message)

        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> put_status(500)
        |> render(:"500")
    end
  end

  defp missing_reference(conn, params) do
    with slug <- params["slug"],
         # TODO Calling this twice seems suboptimal
         {:ok, notes} <- DocumentServer.find_all_by_reference(slug) do
      if length(notes) > 0 do
        render(conn, :show, assigns_from_content(placeholder_reference(slug), notes))
      else
        conn
        |> put_view(SquidtreeWeb.ErrorView)
        |> put_status(404)
        |> render(:"404")
      end
    end
  end

  defp placeholder_reference(slug) do
    %Document{
      id: slug,
      title: ""
    }
  end

  defp assigns_from_content(content, notes),
    do:
      Map.from_struct(content)
      |> Map.merge(%{
        notes: notes,
        layout_name: :reference,
        base_path: "/notes/",
        # TODO
        page_description: ""
      })
end
