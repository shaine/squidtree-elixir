defmodule SquidtreeWeb.BlogView do
  use SquidtreeWeb, :view
  use Timex

  def date_format(date),
    do:
      with(
        {:ok, formatted_date} <- Timex.format(date, "{Mshort} {0D}, {YYYY}"),
        do: formatted_date
      )
end
