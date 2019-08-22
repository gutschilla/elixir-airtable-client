defmodule Airtable.Result.List do
  @moduledoc """
  Represents a List of items as a struct.

  - Contains records as list of type Airtable.Result.Item
  - key `offset` is intended to be used for internal reprensentation of
    pagination (not implemented yet)

  """

  defstruct [records: [], offset: nil]

  @doc ~S"""
  Converts a map (decoded JSON from Airtable, usualle) to a __MODULE__ struct.

  ## Example

      iex>Airtable.Result.List.from_record_maps(
      ...>  %{
      ...>    "records" => [
      ...>      %{"id" => "ID1", "fields" => %{"name" => "Fank", "age" => 23} },
      ...>      %{"id" => "ID2", "fields" => %{"name" => "Lara", "age" => 45} },
      ...>    ]
      ...>  }
      ...>)
      %Airtable.Result.List{
        offset: nil,
        records: [
          %Airtable.Result.Item{fields: %{"age" => 23, "name" => "Fank"}, id: "ID1"},
          %Airtable.Result.Item{fields: %{"age" => 45, "name" => "Lara"}, id: "ID2"}
        ]
      }
  """
  def from_record_maps(map = %{"records" => records}) when is_list(records) do
    offset = map["offset"] # key "offset" may not exist
    %__MODULE__{
      records: Enum.map(records, &Airtable.Result.Item.from_item_map/1),
      offset:  offset
    }
  end

  def from_record_maps(map) do
    raise "malformed list response map: must be map with key \"records\" containing a list of item maps: #{inspect(map)}"
  end
end
