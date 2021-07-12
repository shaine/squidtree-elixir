defmodule SquidtreeWeb.PageController do
  use SquidtreeWeb, :controller

  alias SquidtreeWeb.Router.Helpers
  alias Squidtree.DocumentServer

  @home_description "A place for Shaine Hatch to store his words."

  def index(conn, _params) do
    with {:ok, recent_notes} <- DocumentServer.get_most_recent_notes(3) do
      render(conn, "home.html", %{
        page_description: @home_description,
        layout_name: :home,
        recent_notes: recent_notes
      })
    end
  end

  def about(conn, _params) do
    render(conn, "about.html", %{
      page_description: @home_description,
      layout_name: :page
    })
  end
end
