# Airtable

[![CircleCI](https://circleci.com/gh/gutschilla/elixir-airtable-client.svg?style=svg)](https://circleci.com/gh/gutschilla/elixir-airtable-client)

## Planned Features and open questions

- replicate API features with basic REST features:
  * [x] list
  * [x] create
  * [x] retrieve
  * [x] update
  * [x] replace
  * [x] delete
- [ ] WIP: add filters/queries to list()
- [ ] retrieve all results for a larger set - iterate over offsets, respecting the rate limit of 5/s

## Out-of scope

- act as caching proxies to overcome rate limiting
  * in-memory only first
- change notofications
  * plain callbacks via {module, function, args} tuples
  
These things will be done in a different project as this module with concentrate
on the basic REST features themselves.

[![buddy pipeline](https://app.buddy.works/zwoelf/elixir-airtable-client/pipelines/pipeline/199738/badge.svg?token=fb70ba265872a7640649f628ae57a3dae87c2cb21b49f078558379a232e50968 "buddy pipeline")](https://app.buddy.works/zwoelf/elixir-airtable-client/pipelines/pipeline/199738)

# Intention

Base your own API wrapper by calling this application with specific API keys,
table keys and stuff and also convert `Airtable.Result.Item` structs into
whatever is your best matching thing. Usually you'd want to parse `fields`
contents if said items further:

```elixir
defmodule MyApp.Airtable.Film do

  defstruct title: nil, rental_id: nil, pegi: nil, teaser: nil

  def from_airtable_item(%Airtable.Result.Item{id: id, fields: map}) do
    struct(Film, map) # this will probably more complex in reality
  end

  def list do
    api_key   = Application.get_env(:airtable, :api_key)
    film_base = Application.get_env(:airtable, :film_base)
    with {:ok, %Airtable.Result.Likst{records: records}} <- Airtable.list(api_key, film_base, "films") do
      Enum.map(records, &from_airtable_item/1)
    end
  end
    
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `airtable` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:airtable, "~> 0.4.0"}
  ]
end
```
# Usage

## create
```elixir
{:ok, %Airtable.Result.Item{id: id1, fields: %{"foo" => 1, "bar" => 2}}} = Airtable.create("<API_KEY>", "<TABLE_KEY>", "<TABLE_NAME>", fields: %{"foo" => 1, "bar" => 2})
{:ok, %Airtable.Result.Item{id: id2, fields: %{"foo" => 3, "bar" => 4}}} = Airtable.create("<API_KEY>", "<TABLE_KEY>", "<TABLE_NAME>", fields: %{"foo" => 3, "bar" => 4})
```

## list
```elixir
{:ok, result} = Airtable.list("<API_KEY>", "<table_key>", "<table_name>")
```
yields

```elixir
{:ok ,
  %Airtable.Result.List{
    records: [
      %Airtable.Result.Item{id: ^id1, fields: %{"foo" => 1, "bar" => 2}},
      %Airtable.Result.Item{id: ^id2, fields: %{"foo" => 3, "bar" => 4}},
    ]
  }
}
```

## list certain fields only

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

## get (retrieve)

```elixir
{:ok, get_result} = Airtable.get("<API_KEY>", "<TABLE_KEY>", "<TABLE_NAME>", id1)
```
yields:
```elixir
{:ok, %Airtable.Result.Item{id: id1, fields: %{"foor" => 1, "bar" => 2}}}
```


## replace

This will overwrite all fields in the existing row. Keys not goven in `fields`
map will be nil-ified.

```elixir
{:ok, get_result} = Airtable.replace("<API_KEY>", "<TABLE_KEY>", "<TABLE_NAME>", id1, fields: %{"foo" => 5, "bar" => 6})
```
yields:
```elixir
{:ok, %Airtable.Result.Item{id: id1, fields: %{"foor" => 5, "bar" => 6}}}
```
## update

This will update only those fields present in the argument `fields` map. Alle
others will be kept.

```elixir
{:ok, get_result} = Airtable.update("<API_KEY>", "<TABLE_KEY>", "<TABLE_NAME>", id1, fields: %{"foo" => 7})
```
yields:
```elixir
{:ok, %Airtable.Result.Item{id: id1, fields: %{"foor" => 7, "bar" => 6}}}
```

## delete

```elixir
{:ok, id1} = Airtable.delete("<API_KEY>", "<TABLE_KEY>", "<TABLE_NAME>", id1)
```

# Documentation

A full description of all available calls is on HexDocs:
[https://hexdocs.pm/airtable](https://hexdocs.pm/airtable)
