defmodule Squidtree.DocumentIndexTask do
  @moduledoc "Recurring task that reindexes the filesystem into the cache"

  require Logger

  use Task, restart: :transient

  alias Squidtree.{DocumentServer, DocumentType}

  def start_link(args \\ []) do
    Task.start_link(__MODULE__, :run, args)
  end

  def run do
    perform_indexing()
    run_again()
  end

  defp run_again do
    receive do
    after
      # Run every 5 minutes
      1000 * 60 * 5 ->
        perform_indexing()
        run_again()
    end
  end

  def perform_indexing do
    IO.puts("Starting DocumentIndexTask")

    DocumentServer.destroy_cache()

    DocumentType.types()
    |> Enum.each(fn type ->
      index_type(type)
    end)
  end

  defp index_type(type) do
    with {:ok, files} <- DocumentType.dir_for_content_type(type) |> File.ls() do
      files
      |> Enum.reject(fn file_name -> Regex.match?(~r/^\./, file_name) end)
      |> Enum.map(fn file_name ->
        file_name
        |> String.replace(".md", "")
        |> (fn file_name ->
              IO.puts("Indexing #{type} #{file_name}")
              file_name
            end).()
        |> DocumentServer.get_document(type: type)
      end)
    end
  end
end
