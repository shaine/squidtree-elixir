defmodule SquidtreeWeb.SitemapView do
  use SquidtreeWeb, :view

  import SquidtreeWeb.HierarchicalView

  def format_date(datetime) do
    [datetime.year, datetime.month, datetime.day]
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join("-")
  end
end
