defmodule Please.Config do
  def repo() do
    :please
    |> Application.fetch_env!(Please)
    |> Keyword.get(:repo)
  end

  def app_module do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
    |> to_string()
    |> Macro.camelize()
  end

  def db_prefix do
    :please
    |> Application.fetch_env!(Please)
    |> Keyword.get(:prefix, nil)
  end

  def groups do
    :please
    |> Application.fetch_env!(Please)
    |> Keyword.get(:groups, [])
    |> Enum.map(&maybe_infer_key_and_table/1)
  end

  def subjects do
    :please
    |> Application.fetch_env!(Please)
    |> Keyword.get(:subjects, [:user])
    |> Enum.map(&maybe_infer_key_and_table/1)
  end

  def all_keys do
    [{:global, true} | owner_keys()]
  end

  def owner_keys do
    Enum.map(groups(), & elem(&1, 1))
  end

  defp maybe_infer_key_and_table(spec) when is_atom(spec) do
    assoc =
      spec
      |> Atom.to_string()
      |> String.split(".", trim: true)
      |> List.last()
      |> String.downcase()

    table_name = "#{assoc}s"
    key_name = "#{assoc}_id"
    {spec, key_name, table_name}
  end

  defp maybe_infer_key_and_table({spec, key, table}) do
    {spec, Atom.to_string(key), Atom.to_string(table)}
  end
end
