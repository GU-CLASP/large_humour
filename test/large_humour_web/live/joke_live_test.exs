defmodule LargeHumourWeb.JokeLiveTest do
  use LargeHumourWeb.ConnCase

  import Phoenix.LiveViewTest
  import LargeHumour.JokesFixtures

  @create_attrs %{code: "some code", text: "some text", seed: true}
  @update_attrs %{code: "some updated code", text: "some updated text", seed: false}
  @invalid_attrs %{code: nil, text: nil, seed: false}
  defp create_joke(_) do
    joke = joke_fixture()

    %{joke: joke}
  end

  describe "Index" do
    setup [:create_joke]

    test "lists all jokes", %{conn: conn, joke: joke} do
      {:ok, _index_live, html} = live(conn, ~p"/jokes")

      assert html =~ "Listing Jokes"
      assert html =~ joke.code
    end

    test "saves new joke", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/jokes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Joke")
               |> render_click()
               |> follow_redirect(conn, ~p"/jokes/new")

      assert render(form_live) =~ "New Joke"

      assert form_live
             |> form("#joke-form", joke: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#joke-form", joke: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/jokes")

      html = render(index_live)
      assert html =~ "Joke created successfully"
      assert html =~ "some code"
    end

    test "updates joke in listing", %{conn: conn, joke: joke} do
      {:ok, index_live, _html} = live(conn, ~p"/jokes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#jokes-#{joke.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/jokes/#{joke}/edit")

      assert render(form_live) =~ "Edit Joke"

      assert form_live
             |> form("#joke-form", joke: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#joke-form", joke: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/jokes")

      html = render(index_live)
      assert html =~ "Joke updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes joke in listing", %{conn: conn, joke: joke} do
      {:ok, index_live, _html} = live(conn, ~p"/jokes")

      assert index_live |> element("#jokes-#{joke.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#jokes-#{joke.id}")
    end
  end

  describe "Show" do
    setup [:create_joke]

    test "displays joke", %{conn: conn, joke: joke} do
      {:ok, _show_live, html} = live(conn, ~p"/jokes/#{joke}")

      assert html =~ "Show Joke"
      assert html =~ joke.code
    end

    test "updates joke and returns to show", %{conn: conn, joke: joke} do
      {:ok, show_live, _html} = live(conn, ~p"/jokes/#{joke}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/jokes/#{joke}/edit?return_to=show")

      assert render(form_live) =~ "Edit Joke"

      assert form_live
             |> form("#joke-form", joke: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#joke-form", joke: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/jokes/#{joke}")

      html = render(show_live)
      assert html =~ "Joke updated successfully"
      assert html =~ "some updated code"
    end
  end
end
