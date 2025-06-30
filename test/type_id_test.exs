defmodule TypeIDTest do
  use ExUnit.Case, async: true
  import TypeID, only: :sigils
  doctest TypeID, except: [new: 2]

  describe "new/1" do
    test "returns a new TypeID struct" do
      tid = TypeID.new("test")
      assert is_struct(tid, TypeID)
      assert "test" == TypeID.prefix(tid)
    end
  end

  describe "new/2" do
    test "allows setting the time" do
      time = ~U[1950-12-17 00:00:00Z] |> DateTime.to_unix(:millisecond)
      tid = TypeID.new("test", time: time)
      assert "test" == TypeID.prefix(tid)
      assert "7zegbdn300" <> _ = TypeID.suffix(tid)
    end
  end

  describe "prefix/1" do
    test "returns the prefix of the given TypeID" do
      tid = ~TYPEID"test_01h44had5rfswbvpc383ktj0aa"
      assert "test" == TypeID.prefix(tid)
    end
  end

  describe "sigil_TYPEID/2" do
    test "constructs a TypeID" do
      tid = ~TYPEID"test_01jyzaw6jbe07t67xf6aa22qdd"
      assert "test" == TypeID.prefix(tid)
      assert "01jyzaw6jbe07t67xf6aa22qdd" == TypeID.suffix(tid)
    end

    test "validates prefix" do
      expected = "invalid prefix: _test. cannot start with an underscore"

      assert_raise ArgumentError, expected, fn ->
        ~TYPEID"_test_01jyzaw6jbe07t67xf6aa22qdd"
      end
    end

    test "validates suffix" do
      expected = "invalid base 32 suffix"

      assert_raise ArgumentError, expected, fn ->
        ~TYPEID"test_91jyzaw6jbe07t67xf6aa22qdd"
      end
    end
  end

  describe "suffix/1" do
    test "returns the base 32 suffix of the given TypeID" do
      tid = ~TYPEID"test_01h44had5rfswbvpc383ktj0aa"
      assert "01h44had5rfswbvpc383ktj0aa" == TypeID.suffix(tid)
    end
  end

  describe "serialization" do
    test "to_string/1 and from_string!/1 are idempotent" do
      tid1 = ~TYPEID"test_01h44had5rfswbvpc383ktj0aa"

      tid2 =
        tid1
        |> TypeID.to_string()
        |> TypeID.from_string!()

      assert tid1 == tid2
    end

    test "from_string/1" do
      assert {:ok, _} = TypeID.from_string("test_01h44xf16gf47v3s4khvc3c5ga")
      assert :error == TypeID.from_string("-invalid_01h44xf16gf47v3s4khvc3c5ga")
    end

    test "from!/2 and from/2 validates the prefix" do
      assert_raise ArgumentError, fn ->
        TypeID.from!("-invalid-prefix-", "01h44had5rfswbvpc383ktj0aa")
      end

      assert :error == TypeID.from("-invalid-prefix-", "01h44had5rfswbvpc383ktj0aa")
    end

    test "from!/2 and from/2 validate the suffix" do
      assert_raise ArgumentError, fn ->
        TypeID.from!("test", "0ih44had5rfswbvpc383ktj0aa")
      end

      assert :error == TypeID.from("test", "0ih44had5rfswbvpc383ktj0aa")
    end
  end

  test "verification" do
    tid = ~TYPEID"test_01h44yssjcf5daefvfr0yb70s8"
    assert "test" == TypeID.prefix(tid)
    assert "018909ec-e64c-795a-a73f-6fc03cb38328" == TypeID.uuid(tid)
  end

  describe "Inspect" do
    test "inspects as sigil" do
      assert inspect(~TYPEID"test_01jyzbm384fm3aaq2pvabybpmf") ==
               ~S(~TYPEID"test_01jyzbm384fm3aaq2pvabybpmf")
    end
  end
end
