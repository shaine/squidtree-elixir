defmodule Squidtree.DocumentTest do
  use ExUnit.Case

  alias Squidtree.Document
  alias Squidtree.Document.Tag
  # doctest Squidtree.Document

  @test_module Squidtree.Document
  @test_post_directory Path.join(File.cwd!(), "test/fixtures/blog_contents")

  describe "get_blog_post/1" do
    test "returns a blog post" do
      assert {:ok,
              %Document{
                title: "Fake Post",
                slug: "fake-post",
                author: "Foo bar",
                published_on: ~D[2020-07-01],
                tags: [
                  %Tag{
                    name: "TagA",
                    slug: "taga"
                  },
                  %Tag{
                    name: "tag b",
                    slug: "tag-b"
                  }
                ],
                title_html: "<b>Fake</b> Post",
                content_html: "<p>Section A</p>\n<hr class=\"thin\" />\n<p>Section B</p>\n"
              },
              []} ==
               @test_module.get_blog_post("normal_test", post_directory: @test_post_directory)
    end
  end
end
