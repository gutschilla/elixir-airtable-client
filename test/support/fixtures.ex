defmodule AirtableTest.Fixtures do

  def response_body(:list), do: make_path("list_items.json") |> File.read!
  def response_body(:get),  do: make_path("get_item.json")   |> File.read!

  def make_path(file) do
    priv = :code.priv_dir(:airtable) |> to_string
    priv <> "/fixtures/" <> file
  end

  def get_response do
    {:ok,
     %Mojito.Response{
       body: response_body(:get),
       complete: true,
       headers: [{"content-type", "application/json; charset=utf-8"},],
       status_code: 200
     }
    }
  end

  def list_response do
    {:ok,
     %Mojito.Response{
       body: response_body(:list),
       complete: true,
       headers: [{"content-type", "application/json; charset=utf-8"},],
       status_code: 200
     }
    }
  end
end
