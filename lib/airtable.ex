defmodule Airtable do
  @moduledoc """
  Documentation for Airtable.
  """

  defmodule Result.Item do
    defstruct [id: nil, fields: %{}]
    def from_item_map(%{"id" => id, "fields" => fields}) when is_binary(id) and is_map(fields) do
      %__MODULE__{id: id, fields: fields}
    end
    def from_item_map(map) do
      raise "malformed item. must be map with string \"id\" and \"fields\" as map: #{inspect(map)}"
    end
  end

  defmodule Result.List do
    defstruct [records: [], offset: nil]
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

  def get(api_key, table_key, table_name, item_id) do
    request = make_request(:get, api_key, table_key, table_name, item_id)
    with {:ok, response = %Mojito.Response{}} <- Mojito.request(request) do
      handle_response(:get, response)
    end
  end

  @doc """
  Retrieves all entries.

  ## options

  ### fields:

  list of strings for fields to retrieve only. Remember, that id will always be there.

  ```
  Airtable.list("API_KEY", "app_BASE", "Filme", fields: ["Titel", "Jahr"])
  {:ok,
    %Airtable.Result.List{
      offset: nil,
      records: [
        %Airtable.Result.Item{
          fields: %{"Jahr" => "2004", "Titel" => "Kill Bill Volume 2"},
          id: "rec15b3sYhdEStY1e"
        },
        %Airtable.Result.Item{
          fields: %{"Titel" => "Ein blonder Traum"},
          id: "rec3KUcL7R3AHD3rY"
        },
        ...
      ]
    }
  }
  ```


  - filterByFormula
  - maxRecords
  - maxRecords
  - sort
  - view
  - cellFormat
  - timeZone
  - userLocale

  ## Examples

      iex> Airtable.list("AIRTABLE_API_KEY", "TABLE_KEY", "films", max_records: 1000)
      %Airtable.Result.List%{records: [%Airtable.Result.Item{id: "someid", fields: %{"foo": "bar"}}], offset: "…"}

  """
  def list(api_key, table_key, table_name, options \\ []) do
    request = make_request(:list, api_key, table_key, table_name, options)
    with {:ok, response = %Mojito.Response{}} <- Mojito.request(request) do
      handle_response(:list, response)
    end
  end

  def handle_response(type, response) when type in [:get, :list] do
    with {:status, %Mojito.Response{body: body, status_code: 200}} <- {:status, response},
         {:json, {:ok, map = %{}}}                                 <- {:json,   Jason.decode(body)},
         {:struct, {:ok, item}}                                    <- {:struct, make_struct(type, map)} do
      {:ok, item}
    else
      {reason, details} -> {:error, {reason, details}}
    end
  end

  def make_struct(:get, map) do
    with item = %Airtable.Result.Item{} <- Airtable.Result.Item.from_item_map(map), do: {:ok, item}
  end

  def make_struct(:list, map) do
    with list = %Airtable.Result.List{} <- Airtable.Result.List.from_record_maps(map), do: {:ok, list}
  end

  def make_request(:get, api_key, table_key, table_name, item_id) do
    %Mojito.Request{
      headers: make_headers(api_key),
      method: :get,
      url:    make_url(:get, table_key, table_name, item_id)
    }
  end

  def make_request(:list, api_key, table_key, table_name, options) do
    query = URI.encode_query(query_for_fields(options[:fields]))
    url =
      make_url(:list, table_key, table_name)
      |> URI.parse()
      |> Map.put(:query, query)
      |> URI.to_string()
    %Mojito.Request{
      headers: make_headers(api_key),
      method: :get,
      url: url
    }
  end

  def query_for_fields(field_list) when is_list(field_list) do
    field_list |> Enum.map(fn value -> {"fields[]", value} end)
  end
  def query_for_fields(nil) do
    []
  end

  def make_headers(api_key) when is_binary(api_key) do
    [{"Authorization", "Bearer #{api_key}"}]
  end

  def make_url(:get, table_key, table_name, item_id) do
    [base_url(), table_key, table_name, item_id] |> Enum.join("/")
  end

  def make_url(:list, table_key, table_name) do
    [base_url(), table_key, table_name] |> Enum.join("/")
  end

  defp base_url(), do: "https://api.airtable.com/v0"
end
