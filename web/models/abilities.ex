defmodule Canary.Abilities do
  alias CodeCorps.Category
  alias CodeCorps.Comment
  alias CodeCorps.Organization
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Task
  alias CodeCorps.Preview
  alias CodeCorps.Project
  alias CodeCorps.ProjectCategory
  alias CodeCorps.ProjectSkill
  alias CodeCorps.Role
  alias CodeCorps.RoleSkill
  alias CodeCorps.Skill
  alias CodeCorps.User
  alias CodeCorps.UserCategory
  alias CodeCorps.UserRole
  alias CodeCorps.UserSkill

  alias CodeCorps.CategoryPolicy
  alias CodeCorps.CommentPolicy
  alias CodeCorps.OrganizationPolicy
  alias CodeCorps.OrganizationMembershipPolicy
  alias CodeCorps.TaskPolicy
  alias CodeCorps.PreviewPolicy
  alias CodeCorps.ProjectPolicy
  alias CodeCorps.ProjectCategoryPolicy
  alias CodeCorps.ProjectSkillPolicy
  alias CodeCorps.RolePolicy
  alias CodeCorps.RoleSkillPolicy
  alias CodeCorps.SkillPolicy
  alias CodeCorps.UserPolicy
  alias CodeCorps.UserCategoryPolicy
  alias CodeCorps.UserRolePolicy
  alias CodeCorps.UserSkillPolicy

  defimpl Canada.Can, for: User do
    # NOTE: Canary sets an :unauthorized and a :not_found handler on a config level
    # The problem is, it will still go through the authorization process first and only call the
    # not found handler after the unauthorized handler does its thing. This means that our
    # unauthorized handler will halt the connection and respond, so the not_found handler
    # will never do anything
    #
    # The only solution is to have a catch_all match for the resource being nil, which returns true
    def can?(%User{}, _action, nil), do: true

    def can?(%User{} = current_user, :update, %User{} = user), do: UserPolicy.update?(user, current_user)

    def can?(%User{} = user, :create, Category), do: CategoryPolicy.create?(user)
    def can?(%User{} = user, :update, %Category{}), do: CategoryPolicy.update?(user)

    def can?(%User{} = user, :create, Comment), do: CommentPolicy.create?(user)
    def can?(%User{} = user, :update, %Comment{} = comment), do: CommentPolicy.update?(user, comment)

    def can?(%User{} = user, :create, Organization), do: OrganizationPolicy.create?(user)
    def can?(%User{} = user, :update, %Organization{} = organization), do: OrganizationPolicy.update?(user, organization)

    def can?(%User{} = user, :create, OrganizationMembership), do: OrganizationMembershipPolicy.create?(user)
    def can?(%User{} = user, :update, %OrganizationMembership{} = membership), do: OrganizationMembershipPolicy.update?(user, membership)
    def can?(%User{} = user, :delete, %OrganizationMembership{} = membership), do: OrganizationMembershipPolicy.delete?(user, membership)

    def can?(%User{} = user, :create, Task), do: TaskPolicy.create?(user)
    def can?(%User{} = user, :update, %Task{} = task), do: TaskPolicy.update?(user, task)

    def can?(%User{} = user, :create, Preview), do: PreviewPolicy.create?(user)

    def can?(%User{} = user, :create, Project), do: ProjectPolicy.create?(user)
    def can?(%User{} = user, :update, %Project{} = project), do: ProjectPolicy.update?(user, project)

    def can?(%User{} = user, :create, ProjectCategory), do: ProjectCategoryPolicy.create?(user)
    def can?(%User{} = user, :delete, %ProjectCategory{}), do: ProjectCategoryPolicy.delete?(user)

    def can?(%User{} = user, :create, ProjectSkill), do: ProjectSkillPolicy.create?(user)
    def can?(%User{} = user, :delete, %ProjectSkill{}), do: ProjectSkillPolicy.delete?(user)

    def can?(%User{} = user, :create, Role), do: RolePolicy.create?(user)

    def can?(%User{} = user, :create, RoleSkill), do: RoleSkillPolicy.create?(user)
    def can?(%User{} = user, :delete, %RoleSkill{}), do: RoleSkillPolicy.delete?(user)

    def can?(%User{} = user, :create, Skill), do: SkillPolicy.create?(user)

    def can?(%User{} = user, :create, %Ecto.Changeset{data: %CodeCorps.UserCategory{}} = changeset), do: UserCategoryPolicy.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserCategory{} = user_category), do: UserCategoryPolicy.delete?(user, user_category)

    def can?(%User{} = user, :create, %Ecto.Changeset{data: %CodeCorps.UserRole{}} = changeset), do: UserRolePolicy.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserRole{} = user_role), do: UserRolePolicy.delete?(user, user_role)

    def can?(%User{} = user, :create, %Ecto.Changeset{data: %CodeCorps.UserSkill{}} = changeset), do: UserSkillPolicy.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserSkill{} = user_skill), do: UserSkillPolicy.delete?(user, user_skill)
  end
end
