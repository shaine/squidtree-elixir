defmodule Squidtree.Document.Tag do
  @moduledoc false
  @enforce_keys [:name, :slug]

  defstruct name: "",
            slug: ""
end

defmodule Squidtree.Document do
  alias Squidtree.Document.Tag
  alias __MODULE__

  @moduledoc false

  defstruct id: nil,
            title: "",
            title_slug: "",
            author: "",
            published_on: nil,
            tags: [],
            title_html: "",
            content_html: ""

  def get_content(slug, options \\ []) do
    with {:ok, metadata, content_md} <- fetch_raw_blog_post(slug, options) do
      blog_post_token(slug)
      |> set_title_html(metadata)
      |> set_title(metadata)
      |> set_published_on(metadata)
      |> set_title_slug(metadata)
      |> set_author(metadata)
      |> set_tags(metadata)
      |> set_content_html(content_md)
    end
  end

  defp fetch_raw_blog_post(slug, options) do
    with {:ok, markdown} <- path_to_post_for_slug(slug, options) |> File.read(),
         [yaml | body_segments] <-
           markdown |> String.split("---\n", trim: true) |> ensure_metadata,
         {:ok, metadata} <- YamlElixir.read_from_string(yaml),
         metadata <- Map.put(metadata, :slug, slug),
         content_md <- body_segments |> Enum.join("---\n") do
      {:ok, metadata, content_md}
    end
  end

  defp path_to_post_for_slug(slug, options) do
    Path.join(
      Keyword.get(
        options,
        :post_directory,
        Path.join(:code.priv_dir(:squidtree), "blog_contents")
      ),
      "#{slug}.md"
    )
  end

  defp ensure_metadata(body_segments) when length(body_segments) > 1, do: body_segments
  defp ensure_metadata(body_segments) when length(body_segments) == 1, do: ["" | body_segments]

  defp blog_post_token(slug), do: {:ok, %Document{id: slug}, []}

  defp set_field(value, {status, blog_post, warnings}, key) do
    {status, %{blog_post | key => value}, warnings}
  end

  defp set_warning(warning, {_status, blog_post, warnings}) do
    {:error, blog_post, [warning | warnings]}
  end

  defp set_title_html(token, metadata) do
    metadata["title"]
    |> set_field(token, :title_html)
  end

  defp set_title(token, metadata) do
    Map.get(metadata, "title", metadata[:slug])
    |> HtmlSanitizeEx.strip_tags()
    |> set_field(token, :title)
  end

  defp set_published_on(token, %{"published_at" => date_string}),
    do: set_published_on_from_string(token, to_string(date_string))

  defp set_published_on(token, %{"date" => date_string}),
    do: set_published_on_from_string(token, to_string(date_string) <> ":00")

  defp set_published_on(token, _metadata),
    do: set_field(DateTime.utc_now(), token, :published_on)

  defp set_published_on_from_string(token, date_string) do
    with raw_published_at <- date_string,
         {:ok, date_time} <- NaiveDateTime.from_iso8601(raw_published_at),
         date <- NaiveDateTime.to_date(date_time) do
      date |> set_field(token, :published_on)
    else
      {:error, message} ->
        set_warning(
          "published_on #{message}: #{date_string}",
          set_field(date_string, token, :published_on)
        )
    end
  end

  defp set_title_slug({_status, blog_post, _warnings} = token, _metadata) do
    blog_post.title
    |> Slug.slugify()
    |> set_field(token, :title_slug)
  end

  defp set_author(token, metadata) do
    metadata["author"]
    |> set_field(token, :author)
  end

  defp set_tags(token, %{"tags" => nil} = metadata),
    do: set_tags(token, %{metadata | "tags" => ""})

  defp set_tags(token, %{"tags" => tags}) do
    tags
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_tag/1)
    |> set_field(token, :tags)
  end

  defp set_tags(token, _metadata), do: set_field([], token, :tags)

  defp parse_tag(raw_tag) do
    %Tag{
      name: raw_tag,
      slug: Slug.slugify(raw_tag)
    }
  end

  defp set_content_html(token, content_md) do
    case Earmark.as_html(content_md, wikilinks: true) do
      {:ok, content_html, _warnings} ->
        set_field(content_html, token, :content_html)

      {:error, message} ->
        set_warning("content_html: #{message}", token)
    end
  end
end
