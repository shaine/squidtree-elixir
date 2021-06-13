defmodule SquidtreeWeb.NoteView do
  use SquidtreeWeb, :view
  use Timex

  def date_format(%Date{} = date) do
    with {:ok, formatted_date} <- Timex.format(date, "{YYYY}-{Mshort}-{0D}"), do: formatted_date
  end

  def date_format(date), do: date
end
