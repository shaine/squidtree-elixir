defmodule Squidtree.FolgezettelTest do
  use ExUnit.Case, async: true

  import Squidtree.Folgezettel

  describe "contains?/2" do
    test "A contains A1" do
      assert contains?("A", "A1") == true
      assert contains?("A1", "A") == false
    end

    test "A contains A1B" do
      assert contains?("A", "A1B") == true
      assert contains?("A1B", "A") == false
    end

    test "A1,1 contains A1,1B" do
      assert contains?("A1,1", "A1,1B") == true
      assert contains?("A1,1B", "A1,1") == false
    end

    test "A1 does not contain B" do
      assert contains?("A1", "B") == false
      assert contains?("B", "A1") == false
    end
  end

  describe "sort_ids/2" do
    test "A < AA" do
      assert sort_ids("AA", "A") == false
      assert sort_ids("A", "AA") == true
    end

    test "A < B" do
      assert sort_ids("B", "A") == false
      assert sort_ids("A", "B") == true
    end

    test "A < A1" do
      assert sort_ids("A1", "A") == false
      assert sort_ids("A", "A1") == true
    end

    test "A1 < A1A" do
      assert sort_ids("A1", "A1A") == true
      assert sort_ids("A1A", "A1") == false
    end

    test "C1 < C9" do
      assert sort_ids("C9", "C1") == false
      assert sort_ids("C1", "C9") == true
    end

    test "C9 < C10" do
      assert sort_ids("C10", "C9") == false
      assert sort_ids("C9", "C10") == true
    end

    test "B9 < C1" do
      assert sort_ids("C1", "B9") == false
      assert sort_ids("B9", "C10") == true
    end

    test "A == A" do
      assert sort_ids("A", "A") == true
    end

    test "0 < A" do
      assert sort_ids("A", "0") == false
      assert sort_ids("0", "A") == true
    end

    test "'' < A" do
      assert sort_ids("", "A") == true
      assert sort_ids("A", "") == false
    end

    test "1 < 1,2" do
      assert sort_ids("1", "1,2") == true
      assert sort_ids("1,2", "1") == false
    end

    test "1,2 < 1,2a" do
      assert sort_ids("1,2", "1,2a") == true
      assert sort_ids("1,2a", "1,2") == false
    end

    test "1,2,3 < 1,2a" do
      assert sort_ids("1,2,3", "1,2a") == true
      assert sort_ids("1,2a", "1,2,3") == false
    end

    test "0G2B3A1 < 0G6E" do
      assert sort_ids("0G2B3A1", "0G6E") == true
      assert sort_ids("0G6E", "0G2B3A1") == false
    end

    @tag :skip # Not sure we want this rule
    test "1a < 1,1" do
      assert sort_ids("1a", "1,1") == true
      assert sort_ids("1,1", "1a") == false
    end
  end

  describe "decompose_id_into_component_groups/1" do
    test "Letters & numbers have different levels: 'A1' becomes ['A', '1']" do
      assert decompose_id_into_component_groups("A1") == [["A", 1]]
    end

    test "Letters & numbers stay in the same level: 'BB69' becomes ['BB', '69']" do
      assert decompose_id_into_component_groups("BB69") == [["BB", 69]]
    end
  end
end
