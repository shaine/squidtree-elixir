defmodule SquidtreeWeb.PageController do
  use SquidtreeWeb, :controller

  alias SquidtreeWeb.Router.Helpers
  alias Squidtree.DocumentServer

  @home_description "A place for Shaine Hatch to store his words."
  @about_description "Squidtree is a place for Shaine Hatch to keep his words, in the form of Zettelkasten notes and blog content."

  def index(conn, _params) do
    with {:ok, recent_notes} <- DocumentServer.get_most_recent_notes(3),
         {:ok, recent_blog_posts} <- DocumentServer.get_most_recent_blog_posts(3) do
      render(conn, "home.html", %{
        page_description: @home_description,
        layout_name: :home,
        recent_notes: recent_notes,
        recent_blog_posts: recent_blog_posts
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
