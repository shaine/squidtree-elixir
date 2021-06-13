defmodule SquidtreeWeb.PageController do
  use SquidtreeWeb, :controller

  alias SquidtreeWeb.Router.Helpers

  def index(conn, _params),
    do: render(conn, "home.html", %{layout_name: :home})
end
