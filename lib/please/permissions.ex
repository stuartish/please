defmodule Please.Permissions do

  import Please.Config, only: [repo: 0, all_keys: 0, owner_keys: 0]

  defmacro __using__ do
    quote do
      import Please.Permissions
      Module.register_attribute(__MODULE__, :permissions_list, accumulate: true)
    end
  end

  defmacro permission(atom, _description) do
    name = Atom.to_string(atom)
    func_name = "may_#{name}?"

    quote do
      @permissions_list unquote(name)

      def unquote(func_name)(subject, resource \\ nil) do
        may?(subject, unquote(name), resource)
      end
    end
  end

  @doc """
  subject is permitted to perform this operation, optionally specific to a resource
  """
  def may?(subject, permission, resource \\ nil) do
    keys = [{:global, true} | get_owner_keys(resource)]
    permissions = get_permissions(subject)
    Enum.any?(keys, & permission in permissions[elem(&1,0)][elem(&1,1)])
  end

  # """
  #   %{
  #     global: %{
  #       true => [list of permissions],
  #     },
  #     org_type_1: %{
  #       org_type1_id1 => [list of permissions],
  #       org_type2_id2 => [list of permissions]
  #       }
  #     }
  #   }
  # """
  defp get_permissions(agent) do
    all_keys = all_keys()

    agent
    |> repo().preload(subject: [subject_group_roles: [:group, :role]])
    |> Map.get(:subject, %{})
    |> Map.get(:subject_group_roles, [])
    |> Enum.group_by(& &1.group_id)
    |> Enum.reduce(Enum.map(all_keys, & %{&1 => %{}}), fn
      {_group_id, [%{group: group} | _] = group_roles}, acc ->
        key = Enum.find(all_keys, &(!!group[&1]))
        permissions_for_group = Enum.flat_map(group_roles, & &1.role.permissions)
        %{acc | key => Map.put(acc[key], group[key], permissions_for_group)}
    end)
  end

  # """
  # for schemas, owner_keys is added at the schema level via a use macro
  # this function will return a list of tuples in the form:
  #     {<field_name_for_owner_foreign_key>, <value_of_foreign_key>}
  # if the function is not defined, fall back to the struct's matching key-value pairs

  # for route-level control, a plug should be used that specifies the key and how to get that parameter
  # doing it this way is not recommended
  # """
  defp get_owner_keys(%{__struct__: module} = resource) do
    if Keyword.has_key?(module.__info__(:functions), :owner_keys) do
      apply(module, :owner_keys, [resource])
    else
      Enum.map(owner_keys(), &{&1, resource[&1]})
    end
  end

  defp get_owner_keys(_), do: []

end
