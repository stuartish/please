defmodule Mix.Tasks.Please.Gen.BaseMigration do
  @shortdoc "Generates Please database migrations"

  @moduledoc """
  Generates migration file the required Please's database migration.

  Note: the prefix provided should reference the same schema that the groups and subjects
  are in. If they are in two different schemas, adapt the following migration instead of running this:

  def change do
    create table(:subjects) do
      add :user_id, :integer
    end
    execute "alter table subjects
              add constraint subjects_user_id_fkey foreign key (user_id)
              references schema1.users (id)
              match simple on update no action on delete no action", ""
    create unique_index(:subjects, [:user_id])
  end

  def change do
    create table(:groups) do
      add :some_org_type_id, :integer
    end
    execute "alter table subjects
              add constraint groups_some_org_type_id_fkey foreign key (some_org_type_id)
              references schema2.some_org_types (id)
              match simple on update no action on delete no action", ""
    create unique_index(:groups, [:some_org_type_id])
  end

  """
  use Mix.Task

  import Mix.Ecto
  import Mix.Generator

  import Please.Config

  @doc false
  def run(args) do
    no_umbrella!("ecto.gen.migration")

    repos = parse_repo(args)

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)
      path = Ecto.Migrator.migrations_path(repo)

      source_path =
        :please
        |> Application.app_dir()
        |> Path.join("priv/templates/base_migration.exs.eex")

      generated_file =
        EEx.eval_file(source_path,
          module_prefix: app_module(),
          db_prefix: db_prefix(),
          groups: groups(),
          subjects: subjects()
        )

      target_file = Path.join(path, "#{timestamp()}_create_please_tables.exs")
      create_directory(path)
      create_file(target_file, generated_file)
    end)
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
