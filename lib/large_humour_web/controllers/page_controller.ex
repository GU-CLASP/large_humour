defmodule LargeHumourWeb.PageController do
  use LargeHumourWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
