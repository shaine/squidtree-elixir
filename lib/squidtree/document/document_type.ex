defmodule Squidtree.DocumentType do
  @moduledoc false

  @types [:note, :reference, :blog]

  def types, do: @types

  def table_name_for_type(type), do: :"#{type}_table"

  def dir_for_content_type(type) when is_atom(type),
    do: "#{type}_contents" |> dir_for_content_type

  def dir_for_content_type(folder) when is_binary(folder),
    do: :code.priv_dir(:squidtree) |> Path.join(folder)
end
