defmodule LargeHumourWeb.RatingLiveTest do
  use LargeHumourWeb.ConnCase

  import Phoenix.LiveViewTest
  import LargeHumour.RatingsFixtures

  @create_attrs %{joke_id: 42, rating: "some rating"}
  @update_attrs %{joke_id: 43, rating: "some updated rating"}
  @invalid_attrs %{joke_id: nil, rating: nil}
  defp create_rating(_) do
    rating = rating_fixture()

    %{rating: rating}
  end

  describe "Index" do
    setup [:create_rating]

    test "lists all ratings", %{conn: conn, rating: rating} do
      {:ok, _index_live, html} = live(conn, ~p"/ratings")

      assert html =~ "Listing Ratings"
      assert html =~ rating.rating
    end

    test "saves new rating", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/ratings")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Rating")
               |> render_click()
               |> follow_redirect(conn, ~p"/ratings/new")

      assert render(form_live) =~ "New Rating"

      assert form_live
             |> form("#rating-form", rating: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#rating-form", rating: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/ratings")

      html = render(index_live)
      assert html =~ "Rating created successfully"
      assert html =~ "some rating"
    end

    test "updates rating in listing", %{conn: conn, rating: rating} do
      {:ok, index_live, _html} = live(conn, ~p"/ratings")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#ratings-#{rating.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/ratings/#{rating}/edit")

      assert render(form_live) =~ "Edit Rating"

      assert form_live
             |> form("#rating-form", rating: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#rating-form", rating: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/ratings")

      html = render(index_live)
      assert html =~ "Rating updated successfully"
      assert html =~ "some updated rating"
    end

    test "deletes rating in listing", %{conn: conn, rating: rating} do
      {:ok, index_live, _html} = live(conn, ~p"/ratings")

      assert index_live |> element("#ratings-#{rating.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#ratings-#{rating.id}")
    end
  end

  describe "Show" do
    setup [:create_rating]

    test "displays rating", %{conn: conn, rating: rating} do
      {:ok, _show_live, html} = live(conn, ~p"/ratings/#{rating}")

      assert html =~ "Show Rating"
      assert html =~ rating.rating
    end

    test "updates rating and returns to show", %{conn: conn, rating: rating} do
      {:ok, show_live, _html} = live(conn, ~p"/ratings/#{rating}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/ratings/#{rating}/edit?return_to=show")

      assert render(form_live) =~ "Edit Rating"

      assert form_live
             |> form("#rating-form", rating: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#rating-form", rating: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/ratings/#{rating}")

      html = render(show_live)
      assert html =~ "Rating updated successfully"
      assert html =~ "some updated rating"
    end
  end
end
