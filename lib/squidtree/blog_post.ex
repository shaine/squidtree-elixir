defmodule Squidtree.BlogPost.Tag do
  @moduledoc false
  @enforce_keys [:name, :slug]

  defstruct name: "",
            slug: ""
end

defmodule Squidtree.BlogPost do
  alias Squidtree.BlogPost.Tag
  alias __MODULE__

  @moduledoc false

  defstruct title: "",
            slug: "",
            author: "",
            published_on: nil,
            tags: [],
            title_html: "",
            content_html: ""

  def get_blog_post(slug, options \\ []) do
    with {:ok, metadata, content_md} <- fetch_raw_blog_post(slug, options) do
      blog_post_token()
      |> set_title_html(metadata)
      |> set_title(metadata)
      |> set_published_on(metadata)
      |> set_slug(metadata)
      |> set_author(metadata)
      |> set_tags(metadata)
      |> set_content_html(content_md)
    end
  end

  defp fetch_raw_blog_post(slug, options) do
    with {:ok, markdown} <- path_to_post_for_slug(slug, options) |> File.read(),
         [yaml | body_segments] <- markdown |> String.split("---\n", trim: true),
         {:ok, metadata} <- YamlElixir.read_from_string(yaml),
         content_md <- body_segments |> Enum.join("---\n") do
      {:ok, metadata, content_md}
    end
  end

  defp path_to_post_for_slug(slug, options) do
    Path.join(
      Keyword.get(
        options,
        :post_directory,
        Path.join(:code.priv_dir(:squidtree), "post_contents")
      ),
      # Reslugify the slug to ensure filepath safety
      "#{Slug.slugify(slug)}.md"
    )
  end

  defp blog_post_token, do: {:ok, %BlogPost{}, []}

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
    metadata["title"]
    |> HtmlSanitizeEx.strip_tags()
    |> set_field(token, :title)
  end

  defp set_published_on(token, metadata) do
    with raw_published_at <- to_string(metadata["published_at"]),
         {:ok, date_time} <- NaiveDateTime.from_iso8601(raw_published_at),
         date <- NaiveDateTime.to_date(date_time) do
      date |> set_field(token, :published_on)
    else
      {:error, message} ->
        set_warning(
          "published_on #{message}",
          set_field(metadata["published_at"], token, :published_on)
        )
    end
  end

  defp set_slug({_status, blog_post, _warnings} = token, _metadata) do
    blog_post.title
    |> Slug.slugify()
    |> set_field(token, :slug)
  end

  defp set_author(token, metadata) do
    metadata["author"]
    |> set_field(token, :author)
  end

  defp set_tags(token, metadata) do
    metadata["tags"]
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_tag/1)
    |> set_field(token, :tags)
  end

  defp parse_tag(raw_tag) do
    %Tag{
      name: raw_tag,
      slug: Slug.slugify(raw_tag)
    }
  end

  defp set_content_html(token, content_md) do
    case Earmark.as_html(content_md) do
      {:ok, content_html, _warnings} ->
        set_field(content_html, token, :content_html)

      {:error, message} ->
        set_warning("content_html: #{message}", token)
    end
  end
end
