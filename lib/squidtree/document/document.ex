defmodule Squidtree.Document.Tag do
  @moduledoc false
  @enforce_keys [:name, :slug]

  defstruct name: "",
            slug: ""
end

defmodule Squidtree.Document do
  @moduledoc false

  defstruct id: nil,
            title: "",
            title_slug: "",
            author: "",
            redirect: nil,
            reference: "",
            reference_slugs: [],
            published_at: nil,
            modified_at: nil,
            tags: [],
            title_html: "",
            content_html: "",
            content_preview: "",
            path: ""
end
