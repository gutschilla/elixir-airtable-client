defmodule Airtable do
  @moduledoc """
  Documentation for Airtable.
  """

  defmodule Result.Item do
    defstruct [id: nil, fields: %{}]
    def from_record_map(map) do
      %__MODULE__{id: map["id"], fields: map["fields"]}
    end
  end

  defmodule Result.List do
    defstruct [records: [], offset: nil]
    def from_record_maps(records, offset \\ nil) do
      %__MODULE__{
        records: Enum.map(records, &Airtable.Result.Item.from_record_map/1),
        offset:  offset
      }
    end
  end

  @doc """
  Retrieves all entries.

  ## Options

  - fields
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
  def list(api_key, table_key, table_name) do
    request = make_request(:list, api_key, table_key, table_name)
    with {:ok, response = %Mojito.Response{}} <- Mojito.request(request) do
      handle_response(:list, response)
    end
  end

  def handle_response(:list, response) do
    with {:status, %Mojito.Response{body: body, status_code: 200}} <- {:status,  response},
         {:json, {:ok, json = %{"records" => records}}}            <- {:json,    Jason.decode(body)},
         {:structs, list = %Airtable.Result.List{}}                <- {:structs, Airtable.Result.List.from_record_maps(records, json["offset"])} do
      {:ok, list}
    else
      {reason, details} -> {:error, {reason, details}}
    end
  end

  def make_request(:list, api_key, table_key, table_name) do
    %Mojito.Request{
      headers: make_headers(api_key),
      method: :get,
      url:    make_url(table_key, table_name)
    }
  end

  def make_headers(api_key) when is_binary(api_key) do
    [{"Authorization", "Bearer #{api_key}"}]
  end

  def make_url(table_key, table_name) do
    Enum.join([base_url(), table_key, table_name], "/")
  end

  defp base_url(), do: "https://api.airtable.com/v0"
end
