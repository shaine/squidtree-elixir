defmodule SquidtreeWeb.ReferenceView do
  use SquidtreeWeb, :view

  def month_format(%NaiveDateTime{} = date) do
    with {:ok, formatted_date} <- Timex.format(date, "{Mfull}"), do: formatted_date
  end
end
