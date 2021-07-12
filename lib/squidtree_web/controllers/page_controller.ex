defmodule SquidtreeWeb.PageController do
  use SquidtreeWeb, :controller

  alias SquidtreeWeb.Router.Helpers
  alias Squidtree.DocumentServer

  @home_description "A website where Shaine Hatch (humbly) commemorates himself."

  def index(conn, _params) do
    with {:ok, recent_notes} <- DocumentServer.get_most_recent_notes(3) do
      render(conn, "home.html", %{
        page_description: @home_description,
        layout_name: :home,
        recent_notes: recent_notes
      })
    end
  end
end
