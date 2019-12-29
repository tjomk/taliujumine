defmodule AppWeb.CheckinControllerTest do
  use AppWeb.ConnCase

  alias App.Places
  alias App.Places.Checkin

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:checkin) do
    {:ok, checkin} = Places.create_checkin(@create_attrs)
    checkin
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all checkins", %{conn: conn} do
      conn = get(conn, Routes.checkin_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create checkin" do
    test "renders checkin when data is valid", %{conn: conn} do
      conn = post(conn, Routes.checkin_path(conn, :create), checkin: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.checkin_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.checkin_path(conn, :create), checkin: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update checkin" do
    setup [:create_checkin]

    test "renders checkin when data is valid", %{conn: conn, checkin: %Checkin{id: id} = checkin} do
      conn = put(conn, Routes.checkin_path(conn, :update, checkin), checkin: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.checkin_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, checkin: checkin} do
      conn = put(conn, Routes.checkin_path(conn, :update, checkin), checkin: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete checkin" do
    setup [:create_checkin]

    test "deletes chosen checkin", %{conn: conn, checkin: checkin} do
      conn = delete(conn, Routes.checkin_path(conn, :delete, checkin))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.checkin_path(conn, :show, checkin))
      end
    end
  end

  defp create_checkin(_) do
    checkin = fixture(:checkin)
    {:ok, checkin: checkin}
  end
end
