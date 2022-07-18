defmodule SquidtreeWeb.HierarchicalView do
  alias Squidtree.Folgezettel

  def recurse_notes([], old_parents, processed), do: %{old_parents: old_parents, processed: Enum.reverse(processed)}
  def recurse_notes(notes), do: recurse_notes(notes, [], [])
  def recurse_notes([note | notes], old_parents, processed) do
    with next_note <- Enum.at(notes, 0),
         current_parents <- current_parents(old_parents, note),
         next_parents <- next_parents(note, next_note, current_parents),
         is_parent <- contains?(note, next_note),
         closed_parents_count <- closeable_parents(old_parents, current_parents) do
      recurse_notes(
        notes,
        next_parents,
        [Map.merge(Map.from_struct(note), %{is_parent: is_parent, closed_parents_count: closed_parents_count}) | processed]
      )
    end
  end

  defp current_parents(old_parents, note) do
    Enum.filter(old_parents, fn parent_id ->
      contains?(parent_id, note.id)
    end)
  end

  defp next_parents(note, next_note, current_parents) do
    if contains?(note, next_note) do
      [note.id | current_parents]
    else
      current_parents
    end
  end

  defp closeable_parents(old_parents, current_parents) do
    length(old_parents) - length(current_parents)
  end

  def contains?(nil, _note_b), do: false
  def contains?(_note_a, nil), do: false
  def contains?(note_a, note_b) when is_binary(note_a) and is_binary(note_b) do
    Folgezettel.contains?(note_a, note_b)
  end
  def contains?(%{} = note_a, %{} = note_b) do
    Folgezettel.contains?(note_a.id, note_b.id)
  end
end
