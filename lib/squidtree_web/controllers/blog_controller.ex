defmodule SquidtreeWeb.BlogController do
  use SquidtreeWeb, :controller

  def show(conn, _params) do
    {:ok, markdown} = File.read(Path.join(:code.priv_dir(:squidtree), "post_contents/test.md"))
    # Only the top HR delineates metadata - the rest is content
    [yaml | body] = markdown |> String.split("---\n", trim: true)

    {:ok, parsed_metadata} = YamlElixir.read_from_string(yaml)

    {:ok, content, _warnings} =
      body
      |> Enum.join("---\n")
      |> Earmark.as_html()

    render(conn, "show.html",
      author: parsed_metadata["author"],
      content: content,
      published_on: parse_datetime_string_to_date(parsed_metadata["published_at"]),
      tags: parse_tags(parsed_metadata["tags"]),
      title: parsed_metadata["title"]
    )
  end

  defp parse_tags(raw_tags) do
    raw_tags
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_tag/1)
  end

  defp parse_tag(raw_tag) do
    %{
      name: raw_tag,
      slug: Slug.slugify(raw_tag)
    }
  end

  defp parse_datetime_string_to_date(datetime_string) do
    with {:ok, date_time} <- NaiveDateTime.from_iso8601(datetime_string),
         date <- NaiveDateTime.to_date(date_time) do
      date
    end
  end
end
