defmodule AirtableTest.Fixtures do

  def list_response_json_body, do: make_path("list_films.json") |> File.read!

  def make_path(file) do
    priv = :code.priv_dir(:airtable) |> to_string
    priv <> "/fixtures/" <> file
  end

  def list_response do
    {:ok,
     %Mojito.Response{
       body: list_response_json_body(),
       complete: true,
       headers: [
         {"access-control-allow-headers",
          "authorization,content-length,content-type,user-agent,x-airtable-application-id,x-airtable-user-agent,x-api-version,x-requested-with"},
         {"access-control-allow-methods", "DELETE,GET,OPTIONS,PATCH,POST,PUT"},
         {"access-control-allow-origin", "*"},
         {"content-type", "application/json; charset=utf-8"},
         {"date", "Thu, 18 Jul 2019 13:33:45 GMT"},
         {"etag", "W/\"236ab-dAaoezhb7P0ldas0fDGppWgWpD0\""},
         {"server", "Tengine"},
         {"set-cookie",
          "brw=brw71Goqn1UMKQC7J; path=/; expires=Sat, 18 Jul 2020 13:33:45 GMT; domain=.airtable.com; secure; httponly"},
         {"strict-transport-security",
          "max-age=31536000; includeSubDomains; preload"},
         {"vary", "Accept-Encoding"},
         {"content-length", "145067"},
         {"connection", "keep-alive"}
       ],
       status_code: 200
     }
    }
  end
end
