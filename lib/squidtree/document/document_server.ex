defmodule Squidtree.DocumentServer do
  @moduledoc false

  require Logger

  use GenServer

  alias Squidtree.{Document, DocumentFileClient, DocumentParser, DocumentType}

  def start_link(opts \\ []) do
    IO.puts("Starting DocumentServer")

    GenServer.start_link(
      __MODULE__,
      [],
      opts
    )
  end

  def get_note(note_id), do: get_document(note_id, type: :note)
  def get_blog(slug), do: get_document(slug, type: :blog)
  def get_reference(slug), do: get_document(slug, type: :reference)

  def get_document(slug, type: type) do
    with {:ok, %{modified_at: modified_at}} <-
           DocumentFileClient.fetch_file_metadata(slug, type: type),
         {:ok, document} <- fetch_document(slug, type: type, modified_at: modified_at) do
      {:ok, document}
    else
      {:not_found} ->
        IO.puts("Cache destroy #{type} #{slug}")
        destroy_cache(slug, type)
        {:not_found}

      {:not_found, _reason} ->
        IO.puts("Cache destroy #{type} #{slug}")
        destroy_cache(slug, type)
        {:not_found}

      err ->
        err
    end
  end

  defp fetch_document(slug, type: type, modified_at: modified_at) do
    case get_cache(slug, type) do
      {:ok, %{modified_at: ^modified_at, document: document}} ->
        IO.puts("Cache hit #{type} #{slug}")
        {:ok, document}

      _ ->
        IO.puts("Cache miss #{type} #{slug}")
        cache_from_file(slug, type: type, modified_at: modified_at)
    end
  end

  defp cache_from_file(slug, type: type, modified_at: modified_at) do
    with {:ok, %{modified_at: foobar} = document} <- fetch_from_file(slug, type: type),
         _ <- set_cache(slug, type, %{modified_at: modified_at, document: document}) do
      IO.puts("Modified at #{foobar}")
      {:ok, document}
    else
      err -> IO.puts(err)
    end
  end

  defp fetch_from_file(slug, type: type) do
    with {:ok, raw_markdown} <-
           DocumentFileClient.fetch_raw_markdown(
             slug,
             type: type
           ),
         {:ok, %Document{} = document} <- DocumentParser.get_document(raw_markdown) do
      {:ok, document}
    else
      err -> err
    end
  end

  defp get_cache(slug, type) do
    case GenServer.call(__MODULE__, {:get_cache, type, slug}) do
      [] -> {:not_found}
      [{_slug, result}] -> {:ok, result}
    end
  end

  defp set_cache(slug, type, value) do
    GenServer.call(__MODULE__, {:set_cache, type, slug, value})
  end

  defp destroy_cache(slug, type) do
    GenServer.call(__MODULE__, {:destroy_cache, type, slug})
  end

  def destroy_cache, do: GenServer.call(__MODULE__, {:destroy_cache})

  def find_all_by_reference(reference_slug) do
    {:ok, GenServer.call(__MODULE__, {:get_cache_by_reference, reference_slug})}
  end

  def get_all_references do
    {:ok, GenServer.call(__MODULE__, {:get_all_references})}
  end

  def get_most_recent_notes(count \\ 5) do
    {:ok, GenServer.call(__MODULE__, {:get_recent_notes, count})}
  end

  def get_all_notes do
    {:ok, GenServer.call(__MODULE__, {:get_all_notes})}
  end

  def get_most_recent_references(count \\ 5) do
    {:ok, GenServer.call(__MODULE__, {:get_recent_references, count})}
  end

  def get_most_recent_blog_posts(count \\ 3) do
    {:ok, GenServer.call(__MODULE__, {:get_recent_blog_posts, count})}
  end

  def get_all_blog_posts do
    {:ok, GenServer.call(__MODULE__, {:get_all_blog_posts})}
  end

  # GenServer callbacks

  @impl true
  def handle_call({:get_cache, type, slug}, _from, state) do
    {
      :reply,
      DocumentType.table_name_for_type(type) |> :ets.lookup(slug),
      state
    }
  end

  @impl true
  def handle_call({:set_cache, type, slug, value}, _from, state) do
    {
      :reply,
      DocumentType.table_name_for_type(type) |> :ets.insert({slug, value}),
      state
    }
  end

  @impl true
  def handle_call({:destroy_cache, type, slug}, _from, state) do
    {
      :reply,
      DocumentType.table_name_for_type(type) |> :ets.delete(slug),
      state
    }
  end

  def handle_call({:destroy_cache}, _from, state) do
    {
      :reply,
      DocumentType.types()
      |> Enum.each(fn type -> DocumentType.table_name_for_type(type) |> :ets.delete(type) end),
      state
    }
  end

  @impl true
  def handle_call({:get_cache_by_reference, reference_slug}, _from, state) do
    {
      :reply,
      all_cache_documents(:note)
      |> find_all_by_reference_slug(reference_slug)
      |> sort_documents_by_date,
      state
    }
  end

  @impl true
  def handle_call({:get_all_references}, _from, state) do
    {
      :reply,
      all_cache_documents(:reference) |> sort_documents_by_date(:asc),
      state
    }
  end

  @impl true
  def handle_call({:get_recent_notes, count}, _from, state) do
    {
      :reply,
      all_cache_documents(:note)
      |> sort_documents_by_date(:desc)
      |> exclude_index
      |> Enum.take(count),
      state
    }
  end

  @impl true
  def handle_call({:get_all_notes}, _from, state) do
    {
      :reply,
      all_cache_documents(:note)
      |> sort_documents_by_date(:desc)
      |> exclude_index,
      state
    }
  end

  @impl true
  def handle_call({:get_recent_references, count}, _from, state) do
    {
      :reply,
      all_cache_documents(:reference) |> sort_documents_by_date(:desc) |> Enum.take(count),
      state
    }
  end

  @impl true
  def handle_call({:get_recent_blog_posts, count}, _from, state) do
    {
      :reply,
      all_cache_documents(:blog) |> sort_documents_by_date(:desc) |> Enum.take(count),
      state
    }
  end

  @impl true
  def handle_call({:get_all_blog_posts}, _from, state) do
    {
      :reply,
      all_cache_documents(:blog) |> sort_documents_by_date(:desc),
      state
    }
  end

  defp all_cache_documents(type) do
    :ets.tab2list(DocumentType.table_name_for_type(type))
    |> Enum.map(fn {_slug, %{document: document}} -> document end)
  end

  defp find_all_by_reference_slug(documents, reference_slug) do
    documents
    |> Enum.filter(fn document ->
      Enum.member?(document.reference_slugs, reference_slug)
    end)
  end

  defp sort_documents_by_date(documents, sort_direction \\ :asc),
    do: Enum.sort_by(documents, & &1.published_at, {sort_direction, NaiveDateTime})

  defp exclude_index(documents),
    do: Enum.reject(documents, fn document -> document.id == "index" end)

  @impl true
  def init(_args) do
    DocumentType.types()
    |> Enum.each(fn type ->
      DocumentType.table_name_for_type(type)
      |> :ets.new([:set, :public, :named_table])
    end)

    {:ok, %{}}
  end
end
