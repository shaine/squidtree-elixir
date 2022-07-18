defmodule Squidtree.Folgezettel do
  @moduledoc false

  require Logger

  defstruct id: "",
            id_components: [],
            parent_id: nil

  def contains?(a, b) when is_binary(a) and is_binary(b) do
    List.starts_with?(decompose_id_components(b), decompose_id_components(a))
  end

  def sort_ids(a, b) do
    sort_groups(
      decompose_id_into_component_groups(a),
      decompose_id_into_component_groups(b)
    )
  end

  defp sort_groups([head_a | tail_a], [head_b | tail_b]) do
    cond do
      head_a == head_b -> sort_groups(tail_a, tail_b)
      true -> sort_components(head_a, head_b) # Whatever the component sort is determines the overall sort
    end
  end

  defp sort_groups([], _), do: true
  defp sort_groups(_, []), do: false

  # IDs contain ID groups (separator-demarcated) contain components (alternating alpha/numeric chars)

  defp sort_components([head_a | tail_a], [head_b | tail_b]) do
    cond do
      head_a == head_b -> sort_components(tail_a, tail_b)
      true -> sort_id_component(head_a, head_b)
    end
  end

  defp sort_components([], _), do: true # Left is shallower, so it's smaller
  defp sort_components(_, []), do: false # Left goes deeper, so it's bigger

  # Root: nil < A; nil < 0. Being "less" means higher in the hierarchy for ID structure.
  # Parent-child: A < A1 < A1A
  # Numbering: C1 < C9 < C10
  # "Interrupts": 1 < 1,1 < 1,1,1 < 1,1A
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
  # Elixir handles a < aa, aa < az,, 1 < 12, 12 < 21 already
  defp sort_id_component(a, b) do
    # If we want more types, we should switch this to include
    # Enum.find_index and create a list of the orders of the types
    case [component_type(a), component_type(b)] do
      [:separator, _] -> true
      [:integer, :string] -> true
      _ -> a <= b
    end
  end

  # Turn "A1BB69" into [["A", 1, "BB", 69]] -- break the ID into each of its hierarchical levels.
  # 1,2,3B into [[1], [2], [3, "B"]]
  def decompose_id_into_component_groups(id) when is_binary(id),
    do:
      id
      |> decompose_id_components()
      |> convert_numbers_in_list()
      |> group_by_separator()
      # |> tap(&IO.inspect(&1))

  # Recurse over the ID and add the next bit to the list of ID components
  defp decompose_id_components(id) do
      id
      # Get each _character_ in the string rather than _byte_ (though they should be the same)
      |> String.graphemes()
      |> decompose_id_components([])
  end

  defp decompose_id_components([head | tail], components) do
    decompose_id_components(tail, update_components(head, components))
  end

  # End of recursion, no more bits to pull out of the ID
  defp decompose_id_components([], components), do: Enum.reverse(components)

  # Need to know whether a bit is an integer or letter to decide what to do with it
  defp component_type(string) do
    cond do
      is_number(string) -> :integer
      String.match?(string, ~r/[0-9]+/) -> :integer
      String.match?(string, ~r/[a-z]+/i) -> :string # TODO May need to differentiate upper/lower strings someday
      String.match?(string, ~r/,/) -> :separator
      true -> :unknown
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

  defp convert_numbers_in_list(list), do: convert_numbers_in_list(list, [])

  defp convert_numbers_in_list([head | tail], components) do
    convert_numbers_in_list(tail, [convert_number(head) | components])
  end

  defp convert_numbers_in_list([], components), do: Enum.reverse(components)

  defp convert_number(string) do
    case Integer.parse(string) do
      {integer, ""} -> integer
      _ -> string
    end
  end

  defp group_by_separator(components), do: group_by_separator(components, [], [])

  defp group_by_separator([head | tail], group, groups) do
    case component_type(head) do
      # If the item is a separator, the group is done, move it to the groups and start a new one
      # Reverse the group while adding it cuz it's done (but was created in reverse)
      :separator -> group_by_separator(tail, [], [group | groups])
      # If the item is anything else, add it to the group
      _ -> group_by_separator(tail, [head | group], groups)
    end
  end

  defp group_by_separator([], group, groups) do
    Enum.reverse([Enum.reverse(group) | groups])
  end

  # Concat the two components together -- the're the same type
  defp combine_into_head(value, [head | components]) do
    [head <> value | components]
  end

  # Add the bit as a new entry in the components -- it's of a different hierarchical level than the last entry
  defp add_new_head(value, components) do
    [value | components]
  end
end
