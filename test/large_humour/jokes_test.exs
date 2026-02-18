defmodule LargeHumour.JokesTest do
  use LargeHumour.DataCase

  alias LargeHumour.Jokes

  describe "jokes" do
    alias LargeHumour.Jokes.Joke

    import LargeHumour.JokesFixtures

    @invalid_attrs %{code: nil, text: nil, seed: nil}

    test "list_jokes/0 returns all jokes" do
      joke = joke_fixture()
      assert Jokes.list_jokes() == [joke]
    end

    test "get_joke!/1 returns the joke with given id" do
      joke = joke_fixture()
      assert Jokes.get_joke!(joke.id) == joke
    end

    test "create_joke/1 with valid data creates a joke" do
      valid_attrs = %{code: "some code", text: "some text", seed: true}

      assert {:ok, %Joke{} = joke} = Jokes.create_joke(valid_attrs)
      assert joke.code == "some code"
      assert joke.text == "some text"
      assert joke.seed == true
    end

    test "create_joke/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jokes.create_joke(@invalid_attrs)
    end

    test "update_joke/2 with valid data updates the joke" do
      joke = joke_fixture()
      update_attrs = %{code: "some updated code", text: "some updated text", seed: false}

      assert {:ok, %Joke{} = joke} = Jokes.update_joke(joke, update_attrs)
      assert joke.code == "some updated code"
      assert joke.text == "some updated text"
      assert joke.seed == false
    end

    test "update_joke/2 with invalid data returns error changeset" do
      joke = joke_fixture()
      assert {:error, %Ecto.Changeset{}} = Jokes.update_joke(joke, @invalid_attrs)
      assert joke == Jokes.get_joke!(joke.id)
    end

    test "delete_joke/1 deletes the joke" do
      joke = joke_fixture()
      assert {:ok, %Joke{}} = Jokes.delete_joke(joke)
      assert_raise Ecto.NoResultsError, fn -> Jokes.get_joke!(joke.id) end
    end

    test "change_joke/1 returns a joke changeset" do
      joke = joke_fixture()
      assert %Ecto.Changeset{} = Jokes.change_joke(joke)
    end
  end
end
