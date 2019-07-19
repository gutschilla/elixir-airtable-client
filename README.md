# Airtable

## Planned Features and open questions

- replicate API features with basic REST features:
  * [x] list
  * [ ] create
  * [x] retrieve
  * [ ] update
  * [ ] delete
- [x] add filters/queries to list()
- [ ] retrieve all results for a larger set - iterate over offsets, respecting the rate limit of 5/s
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
    {:airtable, "~> 0.2.1"}
  ]
end
```
# Usage

```elixir
iex> {:ok, result} = Airtable.list("<API_KEY>", "<table_key>", "<table_name>")
%Airtable.Result.List{
  records: [
    %Airtable.Result.Item{id: "idfoobar",  fields: %{"foo" => 1}},
    %Airtable.Result.Item{id: "idboombaz", fields: %{"foo" => 2}},
    …
  ]
}

iex> {:ok, result} = Airtable.get("<API_KEY>", "<TABLE_KEY>", "<TABLE_NAME>", "<ITEM_ID>")
%Airtable.Result.Item{
  id: "<ITEM_ID>",
  fields: %{…}
}
```

retrieve certain fields only

```elixir
iex> Airtable.list("API_KEY", "app_BASE", "Filme", fields: ["title", "year"])
{:ok,
  %Airtable.Result.List{
    offset: nil,
    records: [
      %Airtable.Result.Item{
        fields: %{"year" => "2004", "title" => "Kill Bill Volume 2"},
        id: "recbummibaer12xx"
      },
      %Airtable.Result.Item{
        fields: %{"titke" => "A blonde dream"}, # <-- null and empty "" values will be removed by Airtable itself!
        id: "recfoobarbazbumm"
      },
      ...
    ]
  }
}
```

# Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/airtable](https://hexdocs.pm/airtable).

