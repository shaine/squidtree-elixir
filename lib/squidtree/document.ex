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
            reference: "",
            published_on: nil,
            tags: [],
            title_html: "",
            content_html: "",
            content_preview: ""

  def get_content(slug, options \\ []) do
    with {:ok, raw_content} <- fetch_raw_blog_post(slug, options) do
      document_token(slug, raw_content)
      |> set_title_html
      |> set_title
      |> set_published_on
      |> set_title_slug
      |> set_author
      |> set_reference
      |> set_tags
      |> set_content_html
      |> set_content_preview
    end
  end

  defp fetch_raw_blog_post(slug, options) do
    with {:ok, markdown} <- path_to_post_for_slug(slug, options) |> File.read(),
         [yaml | body_segments] <-
           markdown |> String.split("---\n", trim: true) |> ensure_metadata,
         {:ok, metadata} <- YamlElixir.read_from_string(yaml),
         metadata <- Map.put(metadata, :slug, slug),
         content_md <- body_segments |> Enum.join("---\n"),
         metadata <- Map.put(metadata, :content_md, content_md) do
      {:ok, metadata}
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

  defp document_token(slug, content_data), do: {:ok, %Document{id: slug}, [], content_data}

  defp set_field(value, {status, blog_post, warnings, content_data}, key) do
    {status, %{blog_post | key => value}, warnings, content_data}
  end

  defp set_warning(warning, {_status, blog_post, warnings, content_data}) do
    {:error, blog_post, [warning | warnings], content_data}
  end

  defp set_title_html({_, _, _, %{"title" => title}} = token) do
    set_field(title, token, :title_html)
  end

  defp set_title({_, _, _, content_data} = token) do
    Map.get(content_data, "title", content_data[:slug])
    |> HtmlSanitizeEx.strip_tags()
    |> set_field(token, :title)
  end

  defp set_published_on({_, _, _, %{"published_at" => date_string}} = token),
    do: set_published_on_from_string(token, to_string(date_string))

  defp set_published_on({_, _, _, %{"date" => date_string}} = token),
    do: set_published_on_from_string(token, to_string(date_string) <> ":00")

  defp set_published_on(token),
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

  defp set_title_slug({_status, blog_post, _warnings, _content_data} = token) do
    blog_post.title
    |> Slug.slugify()
    |> set_field(token, :title_slug)
  end

  defp set_author({_, _, _, %{"author" => author}} = token), do: set_field(author, token, :author)
  defp set_author(token), do: set_field(nil, token, :author)

  defp set_reference({_, _, _, %{"citation" => reference}} = token), do: set_field(reference, token, :reference)
  defp set_reference(token), do: set_field(nil, token, :reference)

  defp set_tags({status, blog_post, warnings, %{"tags" => nil} = content_data} = token),
    do: set_tags({status, blog_post, warnings, %{content_data | "tags" => ""}})
  defp set_tags({_, _, _, %{"tags" => tags}} = token) do
    tags
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_tag/1)
    |> set_field(token, :tags)
  end
  defp set_tags(token), do: set_field([], token, :tags)

  defp parse_tag(raw_tag) do
    %Tag{
      name: raw_tag,
      slug: Slug.slugify(raw_tag)
    }
  end

  defp stylize_html(content_html) do
    content_html
    |> String.replace(~r/\(/, "<em>(")
    |> String.replace(~r/\)/, ")</em>")
  end

  defp set_content_html({_, _, _, %{content_md: content_md}} = token) do
    case Earmark.as_html(content_md, wikilinks: true) do
      {:ok, content_html, _warnings} ->
        stylize_html(content_html)
        |> set_field(token, :content_html)

      {:error, message} ->
        set_warning("content_html: #{message}", token)
    end
  end

  defp set_content_preview({_, _, _, %{content_md: content_md}} = token) do
    content_md
    |> String.split("---\n", trim: true) # Split by <hr>s
    |> hd # Just the top section
    |> String.replace(~r/^# .*/m, "") # Remove redundant H1
    |> String.replace(~r/^#+ /m, "") # Remove heading prefixes
    |> String.replace(~r/ ?\[\[[0-9A-Z]*\]\]/m, "") # Remove links & preceding space
    |> String.replace(~r/^ ?+-/m, "") # Remove bullets
    |> String.replace(~r/\n/m, "") # Remove line breaks
    |> String.trim # Remove trailing space
    |> set_field(token, :content_preview)
  end
end
