defmodule Squidtree.DateTimeColor do
  # The hue math in this module is based on this image https://i.stack.imgur.com/pSUUV.jpg
  # The math here linearly moves through the color cycle since the colors approximate the
  # seasonal progression well enouugh
  # 0 matches the color best suited for Aug 1, which makes 210 the color for Jan 1
  @initial_hue_degree 210
  # 360 (exclusive) is the upper limit for hue value because colors are a circle
  @max_hue_degree 360
  @max_days_of_year 365

  # TODO Add color aging

  def hex_color_string_for_date(date) do
    hsl_color_for_date(date)
    |> CssColors.rgb()
    |> to_string
  end

  defp hsl_color_for_date(date),
    do: CssColors.hsl(hue_from_date(date), saturation_from_date(date), lightness_from_date(date))

  defp lightness_from_date(_date), do: 0.7

  defp saturation_from_date(_date), do: 1

  defp hue_from_date(date) do
    ratio_of_year(date)
    # CssColors hues go the opposite direction of the hue number diagram
    |> invert_ratio
    |> hue_without_offset_from_ratio
    |> offset_hue
    |> normalize_hue
  end

  defp ratio_of_year(%Date{} = date), do: Date.day_of_year(date) / @max_days_of_year
  defp ratio_of_year(_date), do: ratio_of_year(Date.utc_today())

  defp invert_ratio(ratio), do: 1 - ratio

  defp hue_without_offset_from_ratio(ratio), do: ratio * @max_hue_degree

  defp offset_hue(unoffset_hue), do: unoffset_hue + @initial_hue_degree

  defp normalize_hue(offset_hue) when offset_hue > @max_hue_degree,
    do: normalize_hue(offset_hue - @max_hue_degree)

  defp normalize_hue(offset_hue), do: offset_hue
end
