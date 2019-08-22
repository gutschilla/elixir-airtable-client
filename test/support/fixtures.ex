defmodule AirtableTest.Fixtures do

  def response_body(:get),    do: make_path("get_item.json")   |> File.read!
  def response_body(:create), do: make_path("get_item.json")   |> File.read! # create returns sent item
  def response_body(:list),   do: make_path("list_items.json") |> File.read!

  def make_path(file) do
    priv = :code.priv_dir(:airtable) |> to_string
    priv <> "/fixtures/" <> file
  end

  def get_response,    do: response(:get)
  def create_response, do: response(:get) # <- create has same response as get
  def list_response,   do: response(:list)

  def response(type) do
    {:ok,
     %Mojito.Response{
       body: response_body(type),
       complete: true,
       headers: [{"content-type", "application/json; charset=utf-8"},],
       status_code: code_for(type)
     }
    }
  end

  def code_for(:get),    do: 200
  def code_for(:create), do: 201
  def code_for(:list),   do: 200

end
