defmodule DayThree do
  alias DayThree.{Accumulator, NumberPosition, AccumulatorPartTwo}

  @valid_symbol_regex ~r/[^\d|^.]/
  @numbers_regex ~r/\d+/
  @gear_regex ~r/\*{1}/

  def part_one(input) do
    %{valid_symbols: valid_symbols, numbers: numbers} =
      input
      |> Enum.with_index()
      |> Enum.reduce(%Accumulator{}, fn {row, row_index}, acc ->
        valid_symbols =
          Regex.scan(@valid_symbol_regex, row, return: :index)
          |> Enum.reduce(%MapSet{}, fn [{col_index, _}], mapset_acc ->
            MapSet.put(mapset_acc, {row_index, col_index})
          end)

        numbers_updated =
          Regex.scan(@numbers_regex, row, return: :index)
          |> Enum.reduce(acc.numbers, fn [{col_index, size}], numbers_acc ->
            is_part_number =
              MapSet.member?(valid_symbols, {row_index, col_index - 1}) or
                MapSet.member?(valid_symbols, {row_index, col_index + size})

            [
              %NumberPosition{
                row: row_index,
                init_col: col_index,
                end_col: col_index + size - 1,
                number: String.to_integer(String.slice(row, col_index, size)),
                is_part_number: is_part_number
              }
              | numbers_acc
            ]
          end)

        %{
          acc
          | valid_symbols: MapSet.union(acc.valid_symbols, valid_symbols),
            numbers: numbers_updated
        }
      end)

    numbers
    |> Enum.reduce([], &check_valid_numbers(&1, &2, valid_symbols))
    |> Enum.filter(&(&1 != nil))
    |> Enum.sum()
  end

  def part_two(input) do
    %{gear_symbols: gear_symbols, numbers: numbers} =
      input
      |> Enum.with_index()
      |> Enum.reduce(%AccumulatorPartTwo{}, fn {row, row_index}, acc ->
        gear_symbols =
          Regex.scan(@gear_regex, row, return: :index)
          |> Enum.reduce(acc.gear_symbols, fn [{col_index, _}], map_acc ->
            Map.put(map_acc, {row_index, col_index}, {0, 1})
          end)

        acc = %{acc | gear_symbols: Map.merge(acc.gear_symbols, gear_symbols)}

        Regex.scan(@numbers_regex, row, return: :index)
        |> Enum.reduce(acc, fn [{col_index, size}],
                               %{gear_symbols: gear_symbols, numbers: numbers} ->
          number = String.to_integer(String.slice(row, col_index, size))

          gear_symbols =
            Map.has_key?(gear_symbols, {row_index, col_index - 1})
            |> update_adjacency_gear_symbol(gear_symbols, {row_index, col_index - 1}, number)

          gear_symbols =
            Map.has_key?(gear_symbols, {row_index, col_index + size})
            |> update_adjacency_gear_symbol(gear_symbols, {row_index, col_index + size}, number)

          numbers = [
            %NumberPosition{
              row: row_index,
              init_col: col_index,
              end_col: col_index + size - 1,
              number: number
            }
            | numbers
          ]

          %{gear_symbols: gear_symbols, numbers: numbers}
        end)
      end)

    numbers
    |> Enum.reduce(gear_symbols, fn %NumberPosition{
                                      row: row,
                                      init_col: init_col,
                                      end_col: end_col,
                                      number: number
                                    },
                                    gear_symbols_acc ->
      Enum.reduce((init_col - 1)..(end_col + 1), gear_symbols_acc, fn col_index,
                                                                      gear_symbols_acc ->
        gear_symbols_acc =
          Map.has_key?(gear_symbols_acc, {row - 1, col_index})
          |> update_adjacency_gear_symbol(gear_symbols_acc, {row - 1, col_index}, number)

        Map.has_key?(gear_symbols_acc, {row + 1, col_index})
        |> update_adjacency_gear_symbol(gear_symbols_acc, {row + 1, col_index}, number)
      end)
    end)
    |> Enum.reduce(0, fn {_, {count, ratio}}, acc ->
      if count == 2 do
        acc + ratio
      else
        acc
      end
    end)
  end

  defp update_adjacency_gear_symbol(false, gear_symbols, _, _), do: gear_symbols

  defp update_adjacency_gear_symbol(true, gear_symbols, key, number) do
    {count, ratio} = Map.get(gear_symbols, key)

    Map.replace(
      gear_symbols,
      key,
      {count + 1, ratio * number}
    )
  end

  defp check_valid_numbers(%NumberPosition{is_part_number: true, number: number}, acc, _) do
    [number | acc]
  end

  defp check_valid_numbers(
         %NumberPosition{row: row, init_col: init_col, end_col: end_col, number: number},
         acc,
         valid_symbols
       ) do
    is_valid =
      Enum.reduce_while((init_col - 1)..(end_col + 1), false, fn col_index, _ ->
        if MapSet.member?(valid_symbols, {row - 1, col_index}) or
             MapSet.member?(valid_symbols, {row + 1, col_index}) do
          {:halt, true}
        else
          {:cont, false}
        end
      end)

    case is_valid do
      true -> [number | acc]
      false -> [nil | acc]
    end
  end
end
