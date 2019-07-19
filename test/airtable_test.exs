defmodule AirtableTest do
  use ExUnit.Case
  # doctest Airtable

  test "get item" do
    {:ok, result} = AirtableTest.Fixtures.get_response()
    {:ok, %Airtable.Result.Item{fields: map, id: id}} = Airtable.handle_response(:get, result)
    assert is_binary(id)
    assert is_map(map)
  end

  test "get list" do
    {:ok, result} = AirtableTest.Fixtures.list_response()
    {:ok, %Airtable.Result.List{records: records}} = Airtable.handle_response(:list, result)
    assert is_list(records)
    assert records |> hd() |> Map.get(:__struct__) == Airtable.Result.Item
  end
end
