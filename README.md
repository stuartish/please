# Please

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `please` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:please, "~> 0.1.0"}
  ]
end
```

## Basic Setup

All you need to do to use Please is add some config, run some generators

Before using Please, add to `config.exs`

```elixir
config :please, Please,
  repo: MyApp.Repo, # required
  db_prefix: <database_schema> # optional, defaults to public schema
  groups: [:org_type_1, :org_type_2]
  subjects: [] \\ [:user]


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/please](https://hexdocs.pm/please).

