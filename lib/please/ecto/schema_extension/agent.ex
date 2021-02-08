defmodule Please.Ecto.SchemaExtension.Agent do
  defmacro __using__() do
    quote do
      import Please.Ecto.SchemaExtension.Agent

    end
  end

  defmacro please_agent_schema() do
    quote do
      has_one(:subject, Please.Ecto.Schema.Subject)
    end
  end
end
