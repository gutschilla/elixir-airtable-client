defmodule AirtableTest do
  use ExUnit.Case
  # doctest Airtable

  test "get list" do
    {:ok, result} = AirtableTest.Fixtures.list_response()
    {:ok, %Airtable.Result.List{records: _records}} = Airtable.handle_response(:list, result)
  end
end
