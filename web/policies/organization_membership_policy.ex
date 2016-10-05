defmodule CodeCorps.OrganizationMembershipPolicy do
  alias CodeCorps.User
  alias CodeCorps.Organization
  alias CodeCorps.OrganizationMembership

  alias CodeCorps.Repo

  import Ecto.Query

  def create?(%User{admin: true}, %Ecto.Changeset{}), do: true
  def create?(%User{id: user_id}, %Ecto.Changeset{changes: %{member_id: member_id}}), do:  user_id == member_id
  def create?(%User{}, %Ecto.Changeset{}), do: false


  def update?(%User{admin: true}, %Ecto.Changeset{}), do: true
  def update?(%User{} = user, %Ecto.Changeset{} = changeset) do
    membership = changeset.data

    user_role = user |> fetch_membership(membership.organization) |> fetch_role
    new_role = changeset |> Ecto.Changeset.get_field(:role)
    old_role = membership.role

    permitted? = case [user_role, old_role, new_role] do
      # Non-member can't do anything
      [nil, _, _] -> false
      # Admins can approve pending memberships and nothing else
      ["admin", "pending", "contributor"] -> true
      # Owners can approve pending memberships, and promote other users
      ["owner", "pending", "contributor"] -> true
      ["owner", "contributor", "admin"] -> true
      ["owner", "admin", "owner"] -> true
      # A non-change in role is allowed
      # [_, role, role] -> true
      # No other role change is allowed
      [_, _, _] -> false
    end

    permitted?
  end

  # user can always leave the organization on their own
  def delete?(%User{} = user, %OrganizationMembership{} = current_membership) do
    user_membership = cond do
      user.id == current_membership.member_id ->
        current_membership
      true ->
        organization = current_membership |> fetch_organization
        user |> fetch_membership(organization)
    end

    permitted? = case user_membership do
      # owner can delete any membership
      %OrganizationMembership{role: "owner"} -> true
      # admin can only delete lower level roles
      %OrganizationMembership{role: "admin"} -> user_membership.role in ["pending", "contributor"]
      # all other members, or non-members, are not permitted
      _ -> false
    end

    permitted?
  end

  defp fetch_organization(%OrganizationMembership{} = membership) do
    Organization
    |> Repo.get(membership.organization_id)
  end
  defp fetch_membership(%User{}, nil), do: nil
  defp fetch_membership(%User{} = user, %Organization{} = organization) do
    OrganizationMembership
    |> where([m], m.member_id == ^user.id and m.organization_id == ^organization.id)
    |> Repo.one
  end

  defp fetch_role(nil), do: nil
  defp fetch_role(%OrganizationMembership{} = membership), do: membership.role
end
