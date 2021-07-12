defmodule Squidtree.DocumentFileClient do
  @moduledoc "Retrieves a markdown file"

  def fetch_file_metadata(slug, type: type) do
    case path_to_post_for_slug(slug, type) |> File.stat() do
      {:ok, %{mtime: modified_at}} -> {:ok, %{modified_at: date_time_from_erl(modified_at)}}
      {:error, :enoent} -> {:not_found, [slug: slug, type: type]}
      {_status, reason} -> {:error, reason}
      _ -> {:error, :unknown}
    end
  end

  defp date_time_from_erl(erl_time) do
    with {:ok, time} <- NaiveDateTime.from_erl(erl_time) do
      time
    end
  end

  def fetch_raw_markdown(slug, type: type) do
    with {:ok, content} <- path_to_post_for_slug(slug, type) |> File.read() do
      {:ok, %{slug: slug, type: type, content: content}}
    end
  end

  defp path_to_post_for_slug(slug, type) do
    Path.join(dir_for_content_type(type), "#{slug}.md")
  end

  defp dir_for_content_type(:blog), do: dir_for_content_type("blog_contents")
  defp dir_for_content_type(:note), do: dir_for_content_type("note_contents")
  defp dir_for_content_type(:reference), do: dir_for_content_type("reference_contents")
  defp dir_for_content_type(folder), do: :code.priv_dir(:squidtree) |> Path.join(folder)
end
