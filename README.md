# Airtable

## Planned Features and open questions

- replicate API features with basic REST features:
  * [x] list
  * [ ] create
  * [ ] retrieve
  * [ ] update
  * [ ] delete
- act as caching proxies to overcome rate limiting
  * in-memory only first
- change notofications
  * plain callbacks via {module, function, args} tuples

[![buddy pipeline](https://app.buddy.works/zwoelf/elixir-airtable-client/pipelines/pipeline/199738/badge.svg?token=fb70ba265872a7640649f628ae57a3dae87c2cb21b49f078558379a232e50968 "buddy pipeline")](https://app.buddy.works/zwoelf/elixir-airtable-client/pipelines/pipeline/199738)

# Intention

Base your own API wrapper by calling this application with specific API keys,
table keys and stuff and also convert `Airtable.Result.Item` structs into
whatever is your best matching thing. Usually you'd want to parse `fields`
contents if said items further.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `airtable` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:airtable, "~> 0.1.0"}
  ]
end
```
# Usage

```elixir
{:ok, result} = Airtable.list("<API_KEY>", "<table_key>", "<table_name>")
%Airtable.Result.List{
  records: [
    %Airtable.Result.Item{
      id: "<SOMEID>",
      fields: %{…}
    }
  ]
}
```

# Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/airtable](https://hexdocs.pm/airtable).

