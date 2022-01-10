defmodule SquidtreeWeb.LayoutView do
  use SquidtreeWeb, :view

  alias Squidtree.DateTimeColor

  def render(template, %{published_at: published_at} = assigns) do
    render_for_date(template, Map.put(assigns, :color_date, published_at))
  end

  def render(template, assigns) do
    render_for_date(template, Map.put(assigns, :color_date, NaiveDateTime.utc_now()))
  end

  defp render_for_date(template, %{color_date: color_date} = assigns) do
    page_title = get_in(assigns, [:title])
    layout_name = get_in(assigns, [:layout_name]) || :page

    page_title =
      case page_title do
        nil -> "Squidtree | Shaine Hatch-related stuff"
        _ -> page_title <> " | Squidtree"
      end

    color = DateTimeColor.hsl_color_for_date(NaiveDateTime.to_date(color_date))

    assigns = put_in(assigns, [:page_title], page_title)
    assigns = put_in(assigns, [:date_color], hex_color_string(color))
    assigns = put_in(assigns, [:date_color_light], lighten_color(color) |> hex_color_string)
    assigns = put_in(assigns, [:date_color_decimals], dec_color_list_string(color))
    assigns = put_in(assigns, [:layout_name], layout_name)
    assigns = put_in(assigns, [:year], DateTime.utc_now().year)

    render_template(template, assigns)
  end

  defp hex_color_string(color) do
    color
    |> CssColors.rgb()
    |> to_string
  end

  defp lighten_color(color), do: CssColors.lighten(color, 0.32)

  defp dec_color_list_string(%CssColors.HSL{} = color),
    do: dec_color_list_string(CssColors.rgb(color))

  defp dec_color_list_string(%{} = color) do
    "#{color.red}, #{color.green}, #{color.blue}"
  end
end
