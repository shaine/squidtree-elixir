defmodule SquidtreeWeb.NoteView do
  use SquidtreeWeb, :view
  use Timex

  def date_format(%NaiveDateTime{} = date) do
    with {:ok, formatted_date} <- Timex.format(date, "{ISOdate}"), do: formatted_date
  end

  def date_format(date), do: date
end
