defmodule Please.Ecto.Schema.SubjectGroupRole do
  use Ecto.Schema

  @primary_key false
  schema "subjects_groups_roles" do
    belongs_to(:subject, Please.Ecto.Schema.Subject, primary_key: true)
    belongs_to(:group, Please.Ecto.Schema.Group, primary_key: true)
    belongs_to(:role, Please.Ecto.Schema.Role, primary_key: true)
  end
end
