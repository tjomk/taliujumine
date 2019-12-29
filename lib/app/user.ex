defmodule App.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string, size: 64
    field :full_name, :string, size: 100
    field :is_staff, :boolean, default: false
    field :password, :string, size: 256
    field :username, :string, size: 32
    has_many :checkins, App.Checkin

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :email, :username, :is_staff, :password])
    |> validate_required([:full_name, :username])
    |> validate_length(:full_name, min: 5)
    |> validate_length(:username, min: 5)
  end
end
