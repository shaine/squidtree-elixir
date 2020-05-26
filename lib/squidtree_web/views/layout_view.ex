defmodule SquidtreeWeb.LayoutView do
  use SquidtreeWeb, :view

  def render(template, assigns) do
    page_title = get_in(assigns, [:meta, :page_title])

    page_title = case page_title do
      nil -> "Squidtree | Shaine Hatch-related stuff"
      _ -> page_title <> " | Squidtree"
    end

    assigns = put_in(assigns, [:meta], %{page_title: page_title})

    render_template(template, assigns)
  end
end
