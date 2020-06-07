defmodule SquidtreeWeb.PageController do
  use SquidtreeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", layout: {SquidtreeWeb.LayoutView, "home.html"})
  end
end
