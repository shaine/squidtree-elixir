defmodule Squidtree.Folgezettel do
  @moduledoc false

  defstruct id: "",
            id_components: [],
            parent_id: nil

  # Root: nil < A; nil < 0. Being "less" means higher in the hierarchy for ID structure.
  # Parent-child: A < A1 < A1A
  # Numbering: C1 < C9 < C10
  # Spreadsheet-style lettering: F9A < F9Z < F9AA < F9AB
  # Realistic ordering looks like: nil, 0, 0A, 0A0, 0A0A, 0A0B, 0A0C, 0A1, 0B... 11A... 12B1... 13AC93
  # where each number/letter switch indicates a parent-child relationship. A child of F is F1 etc.
  # true = "preceding" or "same" in elixir sorting, false = "following"
  def sort_ids(a, _b) when is_nil(a), do: true # nil indicates an earlier level in tree, esp. root node
  def sort_ids(_a, b) when is_nil(b), do: false # nil indicating higher node level means this is not lower
  def sort_ids(a, b) when a == b, do: true # Same is true
  def sort_ids(a, b) when byte_size(a) != byte_size(b), do: byte_size(a) < byte_size(b) # a < aa, 1 < 12
  def sort_ids(a, b) when byte_size(a) == byte_size(b), do: a <= b # Elixir handles aa < az, 12 < 21 already

  # Turn "A1BB69" into ["A", "1", "BB", "69"] -- break the ID into each of its hierarchical levels.
  def decompose_id(id) when is_binary(id),
    do:
      id
      # Efficiently building out the list entails adding items to the head, IE building it backward. Starting with a
      # backward string allows us to build out the correctly ordered set
      |> String.reverse()
      |> String.graphemes() # Get each _character_ in the string rather than _byte_ (though they should be the same)
      |> decompose_id_recursive([])

  # Recurse over the ID and add the next bit to the list of ID components
  defp decompose_id_recursive([head | tail], components) do
    decompose_id_recursive(tail, update_components(head, components))
  end

  # End of recursion, no more bits to pull out of the ID
  defp decompose_id_recursive([], components), do: components

  # Need to know whether a bit is an integer or letter to decide what to do with it
  defp component_type(string) do
    case Integer.parse(string) do
      {_, ""} -> :integer
      _ -> :string
    end
  end

  # First bit assessed starts the list
  defp update_components(value, []), do: [value]

  # When the new bit and the last added bit are of the same type, they're actually part of the same ID component
  # and are added together rather than added as separate entries into the component list
  defp update_components(value, [head | _tail] = components) do
    if component_type(value) == component_type(head) do
      combine_into_head(value, components)
    else
      add_new_head(value, components)
    end
  end

  # Concat the two components together -- the're the same type
  defp combine_into_head(value, [head | components]) do
    [value <> head | components]
  end

  # Add the bit as a new entry in the components -- it's of a different hierarchical level than the last entry
  defp add_new_head(value, components) do
    [value | components]
  end
end
