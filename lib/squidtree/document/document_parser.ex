defmodule Squidtree.DocumentParser do
  @moduledoc "Parses a markdown file into a Document"

  require Logger

  alias Squidtree.Document
  alias Squidtree.Document.Tag

  def get_document(file_description) do
    raw_markdown_from_file(file_description)
    |> document_token
    |> set_title_html
    |> set_title
    |> set_published_at
    |> set_title_slug
    |> set_redirect
    |> set_references
    |> set_reference_slugs
    |> set_tags
    |> set_content_html
    |> set_content_preview
    |> set_path
    |> return_token
  end

  defp raw_markdown_from_file(%{
         content: content,
         slug: slug,
         modified_at: modified_at,
         type: type
       }) do
    with [yaml | body_segments] <-
           content
           |> String.split("---\n", trim: true)
           |> ensure_metadata,
         {:ok, metadata} <-
           patch_yaml(yaml)
           |> YamlElixir.read_from_string(),
         metadata <- Map.put(metadata, :slug, slug),
         content_md <-
           body_segments
           |> Enum.join("---\n"),
         metadata <-
           Map.put(metadata, :content_md, content_md)
           |> Map.put(:modified_at, modified_at)
           |> Map.put(:type, type) do
      metadata
    end
  end

  defp ensure_metadata(body_segments) when length(body_segments) > 1, do: body_segments
  defp ensure_metadata(body_segments) when length(body_segments) == 1, do: ["" | body_segments]

  defp patch_yaml(yaml) do
    yaml
    # Escape double quote so we can...
    |> String.replace("\"", "\\\"")
    # Wrap all YAML values in double quotes to prevent parse errors
    |> String.replace(~r/^(.*?:) (.*)$/m, "\\1 \"\\2\"")
  end

  defp document_token(%{slug: slug, modified_at: modified_at} = content_data),
    do: {:ok, %Document{id: slug, modified_at: modified_at}, [], content_data}

  defp set_field(value, {status, document, warnings, content_data}, key) do
    {status, %{document | key => value}, warnings, content_data}
  end

  defp set_warning(warning, {_status, document, warnings, content_data}) do
    {:error, document, [warning | warnings], content_data}
  end

  defp set_title_html({_, _, _, content_data} = token) do
    Map.get(content_data, "title", content_data[:slug])
    # Make the title a markdown h1. Earmak sometimes needs the text to have a wrapping element...
    |> fn title_text -> "# #{title_text}" end.()
    # This is mostly to access the features of Smartypants, which are not exposed
    |> Earmark.as_html(escape: false)
    |> fn {:ok, parsed_html, _warnings} -> parsed_html end.()
    # Remove the wrapping paragraphs
    |> String.replace(~r/^<h1>/, "")
    |> String.replace(~r/<\/h1>$/, "")
    |> set_field(token, :title_html)
  end

  defp set_title({_, %{title_html: title_html}, _, _} = token) do
    title_html
    |> HtmlSanitizeEx.strip_tags()
    |> String.trim
    |> set_field(token, :title)
  end

  defp set_published_at({_, _, _, %{"published_at" => date_string}} = token),
    do: set_published_at_from_string(to_string(date_string), token)

  defp set_published_at({_, _, _, %{"date" => date_string}} = token) do
    date_string
    |> String.replace(~r/^(\d{4}-\d{2}-\d{2})$/, "\\1 00:00:00")
    |> String.replace(~r/^(\d{4}-\d{2}-\d{2} \d{2}:\d{2})$/, "\\1:00")
    |> set_published_at_from_string(token)
  end

  defp set_published_at(token),
    do: set_field(DateTime.utc_now(), token, :published_at)

  defp set_published_at_from_string(date_string, token) do
    with raw_published_at <- date_string,
         {:ok, date_time} <- NaiveDateTime.from_iso8601(raw_published_at) do
      date_time |> set_field(token, :published_at)
    else
      {:error, message} ->
        set_warning(
          "published_at #{message}: #{date_string}",
          set_field(date_string, token, :published_at)
        )
    end
  end

  defp set_title_slug({_status, document, _warnings, _content_data} = token) do
    document.title
    |> Slug.slugify()
    |> set_field(token, :title_slug)
  end

  defp set_redirect({_status, _document, _warnings, content_data} = token) do
    Map.get(content_data, "redirect")
    |> set_field(token, :redirect)
  end

  defp set_references({_, _, _, %{"citation" => reference}} = token) when is_binary(reference) do
    reference
    |> String.split(";", trim: true)
    |> Enum.map(fn ref -> reference_from_string(ref) end)
    |> set_field(token, :reference)
  end

  defp set_references(token), do: set_field(nil, token, :reference)

  defp reference_from_string(reference_string) do
    if String.match?(reference_string, ~r/^https?:\/\//) do
      %{
        name: String.trim(reference_string),
        url: reference_string
      }
    else
      %{
        name: String.trim(reference_string),
        slug: slugify_reference(reference_string)
      }
    end
  end

  defp slugify_reference(reference),
    do:
      reference
      |> String.replace(~r/[ \-\,]/, "")
      |> Slug.slugify()
      |> String.replace(~r/[-_]+/, "")

  defp set_reference_slugs({_, %{reference: reference}, _, _} = token) when is_list(reference) do
    Enum.map(reference, & &1[:slug]) |> set_field(token, :reference_slugs)
  end

  defp set_reference_slugs(token), do: token

  defp set_tags({status, document, warnings, %{"tags" => nil} = content_data}),
    do: set_tags({status, document, warnings, %{content_data | "tags" => ""}})

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

  defp content_pre_process(content_md) do
    content_md
    # Remove redundant H1
    # Relevant to layouts that separate the H1 from the text
    |> String.replace(~r/^# .*/m, "")
  end

  defp content_post_process(content_html) do
    content_html
    # Add automatic em tags to parens
    |> String.replace(~r/\(/, "<em class=\"auto-em\">(")
    |> String.replace(~r/\)/, ")</em>")
  end

  defp set_content_html({_, _, _, %{content_md: content_md}} = token) do
    case Earmark.as_html(content_md |> content_pre_process, wikilinks: true, escape: false) do
      {:ok, content_html, warnings} ->
        Enum.each(warnings, &Logger.warn/1)

        content_post_process(content_html)
        |> set_field(token, :content_html)

      {:error, message} ->
        set_warning("content_html: #{message}", token)
    end
  end

  defp set_content_preview({_, _, _, %{"description" => description}} = token),
    do: set_field(description, token, :content_preview)

  defp set_content_preview({_, _, _, %{content_md: content_md}} = token) do
    content_md
    # Split by <hr>s
    |> String.split("---\n", trim: true)
    # Just the top section
    |> hd
    # Remove redundant H1
    |> String.replace(~r/^# .*/m, "")
    # Remove heading prefixes
    |> String.replace(~r/^#+ /m, "")
    # Remove links & preceding space
    |> String.replace(~r/ ?\[\[[0-9A-Z]*\]\]/m, "")
    # Remove bullets
    |> String.replace(~r/^ ?+-/m, "")
    # Remove line breaks
    |> String.replace(~r/\n/m, "")
    # Remove trailing space
    |> String.trim()
    |> set_field(token, :content_preview)
  end

  defp format_date(datetime) do
    [datetime.year, datetime.month, datetime.day]
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join("/")
  end

  defp set_path(
         {_status, %{published_at: published_at, id: id}, _warnings, %{type: :blog}} = token
       ) do
    "/blog/#{format_date(published_at)}/#{id}"
    |> set_field(token, :path)
  end

  defp set_path({_status, %{title_slug: title_slug, id: id}, _warnings, %{type: :note}} = token) do
    "/notes/#{title_slug}/#{id}"
    |> set_field(token, :path)
  end

  defp set_path({_status, %{id: id}, _warnings, %{type: :reference}} = token) do
    "/references/#{id}"
    |> set_field(token, :path)
  end

  defp return_token({status, document, warnings, _content_data}) do
    Enum.each(warnings, &Logger.warn/1)
    {status, document}
  end
end
