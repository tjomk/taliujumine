defmodule App.Users do
  @moduledoc """
  The Users context.
  """
  import Ecto.Query, warn: false
  alias Argon2
  alias App.Repo

  alias App.Users.User

  defp normalize(search_string) do
    search_string
    |> String.downcase
    |> String.replace("%", "")
    |> String.replace("'", "")
    |> String.replace(~r/\n/, " ")
    |> String.replace(~r/\t/, " ")
    |> String.replace(~r/\s{2,}/, " ")
    |> String.trim
  end

  @doc """
  Searches user list by full name and username fields.
  Returns the list with filtered results

  ## Examples
  
      iex> search_users("John")
      [%User{}, ...]

  """
  def search_users(search) do
    if String.trim(search) == "" do
      []
    else
      search_string =
        search
        |> normalize
        |> (&("%#{&1}%")).()
      query = from u in User, where: ilike(u.full_name, ^search_string) or ilike(u.username, ^search_string)
      Repo.all(query)
    end
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns :ok and user if the authentication has been successful,
  otherwise and error

  ## Examples

      iex> authenticate_user("email@example.com", "password")
      {:ok, %User{}}

      iex> authenticate_user("email@example.com", "password2")
      {:error, :invalid_credentials}

  """
  def authenticate_user(email, plain_text_password) do
    query = from u in User, where: u.email == ^email
    case Repo.one(query) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
      user ->
        if Argon2.verify_pass(plain_text_password, user.password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

end
