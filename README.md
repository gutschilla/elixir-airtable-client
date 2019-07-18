# Airtable

## Planned Features and open questions

- replicate API features
  * will start with basic REST
- act as caching proxies to overcome rate limiting
  * in-memory only first
- change notofications
  * plain callbacks via {module, function, args} tuples

[![buddy pipeline](https://app.buddy.works/zwoelf/elixir-airtable-client/pipelines/pipeline/199738/badge.svg?token=fb70ba265872a7640649f628ae57a3dae87c2cb21b49f078558379a232e50968 "buddy pipeline")](https://app.buddy.works/zwoelf/elixir-airtable-client/pipelines/pipeline/199738)

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

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/airtable](https://hexdocs.pm/airtable).

