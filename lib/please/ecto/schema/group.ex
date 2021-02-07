defmodule Please.Ecto.Schema.Group do
  use Ecto.Schema

  import Please.Ecto.Schema.Helpers, only: [add_please_groups: 0]

  schema "groups" do
    add_please_groups()
    field(:global, :boolean)
  end
end
