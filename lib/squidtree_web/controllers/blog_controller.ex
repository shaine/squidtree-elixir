defmodule SquidtreeWeb.BlogController do
  use SquidtreeWeb, :controller

  def show(conn, _params) do
    {:ok, markdown} = File.read(Path.join(:code.priv_dir(:squidtree), "post_contents/test.md"))
    [yaml | body] = markdown |> String.split("---\n", trim: true)

    {:ok, parsed_metadata} = YamlElixir.read_from_string(yaml)

    {:ok, content, _warnings} =
      body
      |> Enum.join("---\n")
      |> Earmark.as_html

    render(conn, "show.html", content: content, meta: %{
      page_title: parsed_metadata["title"]
    })
  end
end
