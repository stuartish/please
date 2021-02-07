defmodule Please.Ecto.Schema.Subject do
  use Ecto.Schema

  import Please.Ecto.Schema.Helpers, only: [add_please_subjects: 0]

  schema "subjects" do
    add_please_subjects()
    has_many(:subject_group_roles, SubjectGroupRole)
  end
end
