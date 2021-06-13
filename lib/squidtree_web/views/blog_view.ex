defmodule SquidtreeWeb.BlogView do
  use SquidtreeWeb, :view
  use Timex

  def date_format(%Date{} = date) do
    with {:ok, formatted_date} <- Timex.format(date, "{Mshort} {0D}, {YYYY}"), do: formatted_date
  end

  def date_format(date), do: date

  def last_item?(index, list) do
    index == length(list) - 1
  end
end
