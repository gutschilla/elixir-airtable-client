defmodule AirtableTest do
  use ExUnit.Case

  doctest Airtable.Result.List

  test "get item" do
    {:ok, result} = AirtableTest.Fixtures.get_response()
    {:ok, %Airtable.Result.Item{fields: map, id: id}} = Airtable.handle_response(:get, result)
    assert is_binary(id)
    assert is_map(map)
  end

  test "create item" do
    {:ok, result} = AirtableTest.Fixtures.create_response()
    {:ok, %Airtable.Result.Item{fields: map, id: id}} = Airtable.handle_response(:create, result)
    assert is_binary(id)
    assert is_map(map)
  end

  test "list records" do
    {:ok, result} = AirtableTest.Fixtures.list_response()
    {:ok, %Airtable.Result.List{records: records}} = Airtable.handle_response(:list, result)
    assert is_list(records)
    assert records |> hd() |> Map.get(:__struct__) == Airtable.Result.Item
  end

  test "delete item" do
    {:ok, result} = AirtableTest.Fixtures.delete_response()
    {:ok, id} = Airtable.handle_response(:delete, result)
    assert is_binary(id)
  end

  test "query format for empty opts" do
    request = Airtable.make_request(:list, "API_KEY", "base", "table", [])
    assert request.url |> URI.parse() |> Map.get(:query) == ""
  end

  test "query format for opts as string arrays" do
    request = Airtable.make_request(:list, "API_KEY", "base", "table", fields: ["Titel", "Teaser"], offset: "etr0yEDIvDEQQAX6g/recOiZ470Eq1jtI7p")
    assert request.url |> URI.parse() |> Map.get(:query) == "fields%5B%5D=Titel&fields%5B%5D=Teaser&offset=etr0yEDIvDEQQAX6g%2FrecOiZ470Eq1jtI7p"
  end

  test "query format for opts with camelized names" do
    request = Airtable.make_request(:list, "API_KEY", "base", "table", offset: "etr0yEDIvDEQQAX6g/recOiZ470Eq1jtI7p", max_records: 200)
    assert request.url |> URI.parse() |> Map.get(:query) == "offset=etr0yEDIvDEQQAX6g%2FrecOiZ470Eq1jtI7p&maxRecords=200"
  end

end
