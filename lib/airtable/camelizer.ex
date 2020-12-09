defmodule Airtable.Camelizer do
  def from_atom(atom) do
    atom
    |> to_string()
    |> camelize()
  end

  defp camelize(word) do
    case Regex.split(~r/(?:^|[-_])|(?=[A-Z])/, to_string(word)) do
      words ->
        words
        |> Enum.filter(&(&1 != ""))
        |> camelize_list()
        |> Enum.join()
    end
  end

  defp camelize_list([], _), do: []

  defp camelize_list([h | tail]) do
    [String.downcase(h)] ++ camelize_list(tail, :upper)
  end

  defp camelize_list([h | tail], :upper) do
    [String.capitalize(h)] ++ camelize_list(tail, :upper)
  end
end
