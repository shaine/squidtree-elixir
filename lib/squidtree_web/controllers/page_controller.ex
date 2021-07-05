defmodule SquidtreeWeb.PageController do
  use SquidtreeWeb, :controller

  alias SquidtreeWeb.Router.Helpers

  @home_description "A website where Shaine Hatch (humbly) commemorates himself."

  def index(conn, _params),
    do: render(conn, "home.html", %{page_description: @home_description, layout_name: :home})
end
