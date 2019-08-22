defmodule Airtable.Result.Item do
  @moduledoc """
  Represents a row in a table.

  - Has a string `id.
  - The `fields` key contains a map of decoded JSON fields as retrieved from
    Airtable. Keys in that map will be string-keys.
  """
  defstruct [id: nil, fields: %{}]
  def from_item_map(%{"id" => id, "fields" => fields}) when is_binary(id) and is_map(fields) do
    %__MODULE__{id: id, fields: fields}
  end
  def from_item_map(map) do
    raise "malformed item. must be map with string \"id\" and \"fields\" as map: #{inspect(map)}"
  end
end
