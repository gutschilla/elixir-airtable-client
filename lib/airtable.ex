defmodule Airtable do
  @moduledoc """
  Documentation for Airtable.
  """

  @doc """
  Retrieves a certain row from a table.
  """
  def get(api_key, table_key, table_name, item_id), do: perform(:get, api_key, table_key, table_name, item_id, [])

  @doc """
  Deletes a certain row from a table. Returns {:ok, "DELETED_ID"} on success.
  """
  def delete(api_key, table_key, table_name, item_id), do: perform(:delete, api_key, table_key, table_name, item_id, [])

  @doc """
  Creates a new row by performing a POST request to Airtable. Parameters are
  sent via the _fields_ option. Upload fields just need to be given one or more
  downloadable URLs.

  Airtable.create(
    "AIRTABLE_API_KEY", "TABLE_KEY", "persons",
    fields: %{
      "Name"        => "Martin Gutsch",
      "Notes"       => "formerly knows as gutschilla",
      "Attachments" => [%{"url" => "https://dummyimage.com/600x400/000/fff"}]
    }
  )
  """
  def create(api_key, table_key, table_name, options), do: perform(:create, api_key, table_key, table_name, nil, options)

  @doc ~S"""
  Replaces an existing row with a new one. If you just want to update certain
  fields, use update/5 instead. Returns the replaces item.

  # create
  {:ok, %Airtable.Result.Item{id: id , fields: %{"name": "Frank", age: 55}} = Airtable.create("API_KEY", "TABLE_KEY", "persons", "rec_SOME_ID", fields: %{"name": "Frank", age: 55})
  # overwrite
  {:ok, %Airtable.Result.Item{id: ^id, fields: %{"name": "Martin", age: 39}} = Airtable.replace("API_KEY", "TABLE_KEY", "persons", id, fields: %{"name": "Martin", age: 39})
  """
  def replace(api_key, table_key, table_name, id, options), do: perform(:replace, api_key, table_key, table_name, id, options)

  @doc ~S"""
  Update given fields for a row. Fields not set in this call will be kapt as-is.
  If you want to replace the whole entry/row, use replace/5 instead. Returns the
  updated item.

  # create
  {:ok, %Airtable.Result.Item{id: id , fields: %{"name": "Frank", age: 55}} = Airtable.create("API_KEY", "TABLE_KEY", "persons", "rec_SOME_ID", fields: %{"name": "Frank", age: 55})
  # overwrite, age is still 55
  {:ok, %Airtable.Result.Item{id: ^id, fields: %{"name": "Martin", age: 55}} = Airtable.replace("API_KEY", "TABLE_KEY", "persons", id, fields: %{"name": "Martin"})
  """
  def update(api_key, table_key, table_name, id, options), do: perform(:update, api_key, table_key, table_name, id, options)

  @doc """
  Perfoms the call cycle for :get, :delete, :update, :replace calls.

  - create request struct
  - make actual HTTP request
  - handle JSON response

  """
  def perform(action, api_key, table_key, table_name, item_id, options \\ []) do
    with {:make_request, request}             <- {:make_request, make_request(action, api_key, table_key, table_name, item_id, options)},
         {:ok, response = %Mojito.Response{}} <- Mojito.request(request) do
      handle_response(action, response)
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

  def handle_response(:delete, response) do
    with {:status, %Mojito.Response{body: body, status_code: 200}} <- {:status, response},
         {:json, {:ok, %{"id" => id, "deleted" => true}}}          <- {:json,   Jason.decode(body)} do
      {:ok, id}
    else
      {:status, %Mojito.Response{status_code: 404}} -> {:error, :not_found}
      {reason, details} -> {:error, {reason, details}}
    end
  end

  def handle_response(type, response) when type in [:get, :list, :create, :update, :replace] do
    with {:status, %Mojito.Response{body: body, status_code: 200}} <- {:status, response},
         {:json, {:ok, map = %{}}}                                 <- {:json,   Jason.decode(body)},
         {:struct, {:ok, item}}                                    <- {:struct, make_struct(type, map)} do
      {:ok, item}
    else
      {:status, %Mojito.Response{status_code: 404}} -> {:error, :not_found}
      {reason, details}                             -> {:error, {reason, details}}
    end
  end

  defp make_struct(type, map) when type in [:get, :create, :update, :replace] do
    with item = %Airtable.Result.Item{} <- Airtable.Result.Item.from_item_map(map), do: {:ok, item}
  end

  defp make_struct(:list, map) do
    with list = %Airtable.Result.List{} <- Airtable.Result.List.from_record_maps(map), do: {:ok, list}
  end

  def make_request(type, api_key, table_key, table_name, item_id, options) when type in [:get, :delete, :update, :replace, :create] do
    %Mojito.Request{
      headers: make_headers(api_key),
      method:  method_for(type),
      url:     make_url(table_key, table_name, item_id),
      body:    make_body(options[:fields]),
    }
  end

  def make_request(:list, api_key, table_key, table_name, options) do
    query = URI.encode_query(query_for_fields(options[:fields]))
    url =
      make_url(table_key, table_name)
      |> URI.parse()
      |> Map.put(:query, query)
      |> URI.to_string()
    %Mojito.Request{
      headers: make_headers(api_key),
      method: :get,
      url: url
    }
  end

  defp make_body(nil),       do: ""
  defp make_body(map = %{}), do: Jason.encode!(%{"fields" => map})

  defp method_for(:get),     do: :get
  defp method_for(:create),  do: :post
  defp method_for(:delete),  do: :delete
  defp method_for(:replace), do: :put
  defp method_for(:update),  do: :patch

  defp query_for_fields(field_list) when is_list(field_list) do
    field_list |> Enum.map(fn value -> {"fields[]", value} end)
  end

  defp query_for_fields(nil) do
    []
  end

  defp make_headers(api_key) when is_binary(api_key) do
    [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"},
    ]
  end

  defp make_url(table_key, table_name, item_id \\ nil) do
    [base_url(), table_key, table_name, item_id]
    |> Enum.filter(fn nil -> false; _ -> true end)
    |> Enum.join("/")
  end

  defp base_url(), do: "https://api.airtable.com/v0"
end
