defmodule Please.Ecto.Schema.Helpers do
  defmacro add_please_subjects() do
    Enum.map(Please.Config.subjects(), fn {subject_schema, subject_assoc, _foreign_key} ->
      quote do
        belongs_to(unquote(String.to_atom(subject_assoc)), unquote(subject_schema))
      end
    end)
  end

  defmacro add_please_groups() do
    Enum.map(Please.Config.groups(), fn {group_schema, group_assoc, _foreign_key} ->
      quote do
        belongs_to(unquote(String.to_atom(group_assoc)), unquote(group_schema))
      end
    end)
  end
end
