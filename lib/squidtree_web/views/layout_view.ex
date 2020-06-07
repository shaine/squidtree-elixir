defmodule SquidtreeWeb.LayoutView do
  use SquidtreeWeb, :view

  alias Squidtree.DateTimeColor

  def render(template, %{published_on: published_on} = assigns) do
    render_for_date(template, Map.put(assigns, :color_date, published_on))
  end

  def render(template, assigns) do
    render_for_date(template, Map.put(assigns, :color_date, random_date()))
  end

  defp render_for_date(template, %{color_date: color_date} = assigns) do
    page_title = get_in(assigns, [:title])

    page_title =
      case page_title do
        nil -> "Squidtree | Shaine Hatch-related stuff"
        _ -> page_title <> " | Squidtree"
      end

    color = DateTimeColor.hsl_color_for_date(color_date)

    assigns = put_in(assigns, [:page_title], page_title)
    assigns = put_in(assigns, [:color], hex_color_string(color))
    assigns = put_in(assigns, [:logo_color], hex_color_string(logo_color(color)))
    assigns = put_in(assigns, [:logo_shadow_color], hex_color_string(logo_shadow_color(color)))

    render_template(template, assigns)
  end

  defp random_date do
    {:ok, date} = Date.new(2020, Enum.random(1..12), Enum.random(1..28))
    date
  end

  defp hex_color_string(color) do
    color
    |> CssColors.rgb()
    |> to_string
  end

  defp logo_color(color) do
    CssColors.hsl(CssColors.get_hue(color), 1, 0.5)
    color
  end

  defp logo_shadow_color(color) do
    logo_color(color) |> CssColors.darken(0.2)
  end
end
