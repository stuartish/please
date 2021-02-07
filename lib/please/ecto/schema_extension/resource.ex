defmodule Please.Ecto.SchemaExtension.Resource do
  @doc """
  Adds a function `owner_keys/0` to the module which will return a list in the form
  [
    {first_owner_key, :key_value1},
    {:first_owner_key, :key_value2},
    {:second_owner_key, :key_value3}
  }

  Takes a list as an argument. Each item can be one of
  1. :owner_key -- for schemas which belong to the owner directly, where :owner_key is the field name
  2. {:owner_key, :field_name} -- where the relevant owner_key has another name, such as :recorded_by_id instead of :user_id
  3. {:via_assoc, {:owner_key, :assoc_name}} -- when the owner_key does not exist on this schema, assumes the assoc's primary key is :id
  4. {:via_assoc, {:owner_key, {:assoc_name, :field_name}}} -- when owner key does not exist on this schema
  """
  import Please.Config, only: [repo: 0]

  defmacro __using__(owners) do
    unless is_nil(owners) do
      quote do
        import Please.Ecto.SchemaExtension.Resource

        def owner_keys(resource) do
          owners
          |> unquote()
          |> Enum.map_reduce(resource, &find_owner_keys(&1, &2))
          |> Enum.flat_map(&elem(&1, 0))
        end
      end
    end
  end

  defmacro please_resource_schema() do
    quote do
      has_one(:group, Please.Ecto.Schema.Group)
    end
  end

  def find_owner_keys(owner_key, resource) when is_atom(owner) do
    {{owner_key, resource[owner_key]}, resource}
  end

  def find_owner_keys({:via_assoc, {owner_key, assoc_name}}, resource) when is_atom(assoc_name) do
    %{^assoc_name => assoc_val} = resource = repo().preload(assoc_name)

    results =
      assoc_val
      |> handle_owner_assoc()
      |> Enum.map(&{owner_key, &1})

    {results, resource}
  end

  def find_owner_keys({:via_assoc, {owner_key, {assoc_name, field_name}}}, resource) do
    %{^assoc_name => assoc_val} = resource = repo().preload(assoc_name)

    results =
      assoc_val
      |> handle_owner_assoc(field_name)
      |> Enum.map(&{owner_key, &1})

    {results, resource}
  end

  def find_owner_keys({owner_key, field_name}, resource) do
    {{owner_key, resource[field_name]}, resource}
  end

  def handle_owner_assoc(assoc_value, key \\ :id) when is_list(assoc) do
    Enum.map(assoc_value, &Map.get(&1, key))
  end

  def handle_owner_assoc(assoc_value, key \\ :id) when is_struct(assoc_value) do
    [Map.get(assoc_value, key)]
  end
end
