defmodule SquidtreeWeb.LayoutView do
  use SquidtreeWeb, :view

  alias Squidtree.DateTimeColor

  def render(template, %{published_on: published_on} = assigns) do
    render_for_date(template, Map.put(assigns, :color_date, published_on))
  end

  def render(template, assigns) do
    render_for_date(template, Map.put(assigns, :color_date, Date.utc_today()))
  end

  defp render_for_date(template, %{color_date: color_date} = assigns) do
    page_title = get_in(assigns, [:title])
    layout_name = get_in(assigns, [:layout_name]) || :page

    page_title =
      case page_title do
        nil -> "Squidtree | Shaine Hatch-related stuff"
        _ -> page_title <> " | Squidtree"
      end

    color = DateTimeColor.hsl_color_for_date(color_date)

    assigns = put_in(assigns, [:page_title], page_title)
    assigns = put_in(assigns, [:date_color], hex_color_string(color))
    assigns = put_in(assigns, [:layout_name], layout_name)

    render_template(template, assigns)
  end

  defp hex_color_string(color) do
    color
    |> CssColors.rgb()
    |> to_string
  end
end
