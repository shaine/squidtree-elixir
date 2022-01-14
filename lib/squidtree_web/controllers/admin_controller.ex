require Logger

defmodule SquidtreeWeb.AdminController do
  use SquidtreeWeb, :controller

  alias Squidtree.DocumentIndexTask

  def cache_refresh(conn, _params) do
    DocumentIndexTask.perform_indexing()

    conn
    |> put_view(SquidtreeWeb.ErrorView)
    |> render(:"200")
  end
end
