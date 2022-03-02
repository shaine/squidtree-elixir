defmodule Squidtree.FolgezettelTest do
  use ExUnit.Case, async: true

  import Squidtree.Folgezettel

  describe "sort_ids/2" do
    test "A < AA" do
      assert sort_ids("AA", "A") == false
    end

    test "A < B" do
      assert sort_ids("B", "A") == false
    end

    test "A < A1" do
      assert sort_ids("A1", "A") == false
    end

    test "A1 < A1A" do
      assert sort_ids("A1A", "A1") == false
    end

    test "C1 < C9" do
      assert sort_ids("C9", "C1") == false
    end

    test "C9 < C10" do
      assert sort_ids("C10", "C9") == false
    end

    test "B9 < C1" do
      assert sort_ids("C1", "B9") == false
    end

    test "A == A" do
      assert sort_ids("A", "A") == true
    end

    test "0 < A" do
      assert sort_ids("A", "0") == false
    end

    test "'' < A" do
      assert sort_ids("", "A") == true
    end
  end

  describe "decompose_id/1" do
    test "Letters & numbers have different levels: 'A1' becomes ['A', '1']" do
      assert decompose_id("A1") == ["A", "1"]
    end

    test "Letters & numbers stay in the same level: 'BB69' becomes ['BB', '69']" do
      assert decompose_id("BB69") == ["BB", "69"]
    end
  end
end
