defmodule CodeCorps.OrganizationMembershipController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller

  import CodeCorps.AuthenticationHelpers, only: [authorize: 2, authorized?: 1]

  alias JaSerializer.Params
  alias CodeCorps.OrganizationMembership

  plug :load_resource, model: OrganizationMembership, only: [:update], preload: [:organization, :member], as: :organization_membership
  plug :load_and_authorize_resource, model: OrganizationMembership, only: [:delete]

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params) do
    memberships =
      OrganizationMembership
      |> OrganizationMembership.index_filters(params)
      |> preload([:organization, :member])
      |> Repo.all

    render(conn, "index.json-api", data: memberships)
  end

  def show(conn, %{"id" => id}) do
    membership =
      OrganizationMembership
      |> preload([:organization, :member])
      |> Repo.get!(id)

    render(conn, "show.json-api", data: membership)
  end

  def create(conn, %{"data" => data = %{"type" => "organization-membership"}}) do
    changeset = %OrganizationMembership{} |> OrganizationMembership.create_changeset(Params.to_attributes(data))

    conn = conn |> authorize(changeset)

    if conn |> authorized? do
      case Repo.insert(changeset) do
        {:ok, membership} ->
          membership = membership |> Repo.preload([:member, :organization])

          conn
          |> @analytics.track(:created, membership)
          |> put_status(:created)
          |> put_resp_header("location", organization_membership_path(conn, :show, membership))
          |> render("show.json-api", data: membership)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
      end
    else
      conn
    end
  end

  def update(conn, %{"data" => data = %{"type" => "organization-membership", "attributes" => _params}}) do
    membership = conn.assigns.organization_membership

    changeset = membership |> OrganizationMembership.update_changeset(Params.to_attributes(data))

    conn = conn |> authorize(changeset)

    if conn |> authorized? do
      case Repo.update(changeset) do
        {:ok, membership} ->
          render(conn, "show.json-api", data: membership)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
      end
    else
      conn
    end
  end

  def delete(conn, %{"id" => id}) do
    OrganizationMembership |> Repo.get!(id) |> Repo.delete!

    conn |> send_resp(:no_content, "")
  end
end
