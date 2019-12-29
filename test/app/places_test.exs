defmodule App.PlacesTest do
  use App.DataCase

  alias App.Places

  describe "checkins" do
    alias App.Places.Checkin

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def checkin_fixture(attrs \\ %{}) do
      {:ok, checkin} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Places.create_checkin()

      checkin
    end

    test "list_checkins/0 returns all checkins" do
      checkin = checkin_fixture()
      assert Places.list_checkins() == [checkin]
    end

    test "get_checkin!/1 returns the checkin with given id" do
      checkin = checkin_fixture()
      assert Places.get_checkin!(checkin.id) == checkin
    end

    test "create_checkin/1 with valid data creates a checkin" do
      assert {:ok, %Checkin{} = checkin} = Places.create_checkin(@valid_attrs)
      assert checkin.name == "some name"
    end

    test "create_checkin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Places.create_checkin(@invalid_attrs)
    end

    test "update_checkin/2 with valid data updates the checkin" do
      checkin = checkin_fixture()
      assert {:ok, %Checkin{} = checkin} = Places.update_checkin(checkin, @update_attrs)
      assert checkin.name == "some updated name"
    end

    test "update_checkin/2 with invalid data returns error changeset" do
      checkin = checkin_fixture()
      assert {:error, %Ecto.Changeset{}} = Places.update_checkin(checkin, @invalid_attrs)
      assert checkin == Places.get_checkin!(checkin.id)
    end

    test "delete_checkin/1 deletes the checkin" do
      checkin = checkin_fixture()
      assert {:ok, %Checkin{}} = Places.delete_checkin(checkin)
      assert_raise Ecto.NoResultsError, fn -> Places.get_checkin!(checkin.id) end
    end

    test "change_checkin/1 returns a checkin changeset" do
      checkin = checkin_fixture()
      assert %Ecto.Changeset{} = Places.change_checkin(checkin)
    end
  end
end
