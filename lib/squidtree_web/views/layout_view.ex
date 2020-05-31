defmodule SquidtreeWeb.LayoutView do
  use SquidtreeWeb, :view

  alias Squidtree.DateTimeColor

  def render(template, %{published_on: published_on} = assigns) do
    render_for_date(template, Map.put(assigns, :color_date, published_on))
  end

  def render(template, assigns) do
    render_for_date(template, Map.put(assigns, :color_date, random_date))
  end

  defp render_for_date(template, %{color_date: color_date} = assigns) do
    page_title = get_in(assigns, [:title])

    page_title =
      case page_title do
        nil -> "Squidtree | Shaine Hatch-related stuff"
        _ -> page_title <> " | Squidtree"
      end

    color = DateTimeColor.hex_color_string_for_date(color_date)

    assigns = put_in(assigns, [:page_title], page_title)
    assigns = put_in(assigns, [:color], color)

    render_template(template, assigns)
  end

  defp random_date do
    {:ok, date} = Date.new(2020, Enum.random(1..12), Enum.random(1..28))
    date
  end
end
