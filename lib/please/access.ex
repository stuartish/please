defmodule Please.Access do
  import Please.Config, only: [repo: 0]

  alias Please.Ecto.Schema.{Subject, SubjectGroupRole}

  def grant(agent, roles, organization) when is_list(roles) do
    subject = ensure_subject(agent)
    group = ensure_group(organization)

    subject_group_roles =
      Enum.map(roles, &%{role_id: &1.id, subject_id: subject.id, group_id: group.id})

    repo().insert_all(SubjectGroupRole, subject_group_roles)
  end

  def grant(agent, role, organization) when is_map(role) do
    grant(agent, [role], organization)
  end

  defp ensure_subject(agent) do
    agent
    |> repo().preload([:subject])
    |> Map.get(:subject)
    |> case do
      nil -> agent |> Ecto.build_assoc(agent, :subject) |> repo().insert!()
      %Subject{} = subject -> subject
    end
  end

  defp ensure_group(organization) do
    organization
    |> repo().preload([:group])
    |> Map.get(:group)
    |> case do
      nil -> agent |> Ecto.build_assoc(agent, :group) |> repo().insert!()
      %Subject{} = subject -> subject
    end
  end
end
