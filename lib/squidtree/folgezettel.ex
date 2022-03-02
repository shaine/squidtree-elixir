defmodule Squidtree.Folgezettel do
  @moduledoc false

  defstruct id: "",
            id_components: [],
            parent_id: nil

  def sort_ids(a, b) do
    a_bits = decompose_id(a)
    b_bits = decompose_id(b)

    sort_components(a_bits, b_bits)
  end

  # A1 v A2 starts the same but needs more analysis
  defp sort_components([head_a | tail_a], [head_b | tail_b]) when head_a == head_b and length(tail_a) == length(tail_b), do: sort_components(tail_a, tail_b)
  # A2 v A starts the same but A is necessarily higher since it has no tail
  defp sort_components([head_a | tail_a], [head_b | tail_b]) when head_a == head_b and length(tail_a) > length(tail_b), do: false
  # [] is necessarily higher in the hierarchy than something with more bits to check
  defp sort_components([], [_stuff]), do: true
  # [] is necessarily lower in the hierarchy than something with more bits to check
  defp sort_components([_stuff], []), do: false
  # Same, so true
  defp sort_components([], []), do: true
  # Assuming nothing has been caught yet, time to start comparing specific values
  defp sort_components([head_a | _tail_a], [head_b | _tail_b]), do: sort_id_component(head_a, head_b)

  # Root: nil < A; nil < 0. Being "less" means higher in the hierarchy for ID structure.
  # Parent-child: A < A1 < A1A
  # Numbering: C1 < C9 < C10
  # Spreadsheet-style lettering: F9A < F9Z < F9AA < F9AB
  # Realistic ordering looks like: nil, 0, 0A, 0A0, 0A0A, 0A0B, 0A0C, 0A1, 0B... 11A... 12B1... 13AC93
  # where each number/letter switch indicates a parent-child relationship. A child of F is F1 etc.
  # true = "preceding" or "same" in elixir sorting, false = "following"
  # nil indicates an earlier level in tree, esp. root node
  defp sort_id_component(a, _b) when is_nil(a), do: true
  # nil indicating higher node level means this is not lower
  defp sort_id_component(_a, b) when is_nil(b), do: false
  # Same is true
  defp sort_id_component(a, b) when a == b, do: true
  # a < aa, 1 < 12
  defp sort_id_component(a, b) when byte_size(a) != byte_size(b), do: byte_size(a) < byte_size(b)
  # Elixir handles aa < az, 12 < 21 already
  defp sort_id_component(a, b) when byte_size(a) == byte_size(b), do: a <= b

  # Turn "A1BB69" into ["A", "1", "BB", "69"] -- break the ID into each of its hierarchical levels.
  def decompose_id(id) when is_binary(id),
    do:
      id
      # Efficiently building out the list entails adding items to the head, IE building it backward. Starting with a
      # backward string allows us to build out the correctly ordered set
      |> String.reverse()
      # Get each _character_ in the string rather than _byte_ (though they should be the same)
      |> String.graphemes()
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
