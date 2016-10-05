defmodule CodeCorps.AuthenticationHelpers do
  use Phoenix.Controller

  import Plug.Conn, only: [halt: 1, put_status: 2, assign: 3]
  import Canada.Can, only: [can?: 3]

  def handle_unauthorized(conn = %{assigns: %{authorized: true}}), do: conn
  def handle_unauthorized(conn = %{assigns: %{authorized: false}}) do
    conn
    |> put_status(401)
    |> render(CodeCorps.TokenView, "error.json", message: "Not authorized")
    |> halt
  end

  def handle_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(CodeCorps.ErrorView, "404.json")
    |> halt
  end

  def authorized?(conn), do: conn |> Map.get(:assigns) |> Map.get(:authorized)

  # Used to authorize a resource we provide on our own
  # We need this to authorize based on changeset, since on some
  # records, some types of changes are valid while others are not
  # This is partially adjusted code, taken from canary
  def authorize(conn, %Ecto.Changeset{} = changeset) do
    current_user = conn.assigns |> Map.get(:current_user)
    action = conn.private.phoenix_action

    conn |> assign(:authorized, can?(current_user, action, changeset)) |> handle_unauthorized
  end
end
