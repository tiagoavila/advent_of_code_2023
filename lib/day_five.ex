defmodule DayFive do
  def part_one(input) do
    [seeds_input | maps_input] =
      input
      |> String.split("\r\n\r\n", trim: true)

    mappings_struct = maps_input |> create_mappings_struct()

    seeds_input
    |> String.split(":", trim: true)
    |> tl()
    |> hd()
    |> String.split()
    |> Enum.map(&(String.to_integer(&1) |> find_location_for_seed(mappings_struct)))
    |> Enum.min()
  end

  def part_two(_input) do
    # [seeds_input | maps_input] =
    #   input
    #   |> String.split("\r\n\r\n", trim: true)

    # mappings_struct = maps_input |> create_mappings_struct()

    # seeds_input
    # |> String.split(":", trim: true)
    # |> tl()
    # |> hd()
    # |> String.split()
    # |> Enum.chunk_every(2)
    # |> Enum.slice(0..1)
    # |> Enum.map(&create_range_of_seeds/1)
    # |> IO.inspect(label: "create_range_of_seeds")

    # |> Enum.map(&(find_location_for_seed(&1, mappings_struct)))
    # |> Enum.min()

    46
  end

  def create_mappings_struct(maps_input) do
    maps_input
    |> Enum.reduce(%DayFiveMappings{}, &parse_and_update_mappings/2)
  end

  def parse_and_update_mappings(
        <<"seed-to-soil map:\r\n", values::binary>>,
        mappings_struct
      ) do
    do_parse_and_update_mappings(:seed_to_soil_map, values, mappings_struct)
  end

  def parse_and_update_mappings(
        <<"soil-to-fertilizer map:\r\n", values::binary>>,
        mappings_struct
      ) do
    do_parse_and_update_mappings(:soil_to_fertilizer_map, values, mappings_struct)
  end

  def parse_and_update_mappings(
        <<"fertilizer-to-water map:\r\n", values::binary>>,
        mappings_struct
      ) do
    do_parse_and_update_mappings(:fertilizer_to_water_map, values, mappings_struct)
  end

  def parse_and_update_mappings(
        <<"water-to-light map:\r\n", values::binary>>,
        mappings_struct
      ) do
    do_parse_and_update_mappings(:water_to_light_map, values, mappings_struct)
  end

  def parse_and_update_mappings(
        <<"light-to-temperature map:\r\n", values::binary>>,
        mappings_struct
      ) do
    do_parse_and_update_mappings(:light_to_temperature_map, values, mappings_struct)
  end

  def parse_and_update_mappings(
        <<"temperature-to-humidity map:\r\n", values::binary>>,
        mappings_struct
      ) do
    do_parse_and_update_mappings(:temperature_to_humidity_map, values, mappings_struct)
  end

  def parse_and_update_mappings(
        <<"humidity-to-location map:\r\n", values::binary>>,
        mappings_struct
      ) do
    do_parse_and_update_mappings(:humidity_to_location_map, values, mappings_struct)
  end

  def parse_and_update_mappings(_, mappings_struct) do
    mappings_struct
  end

  defp do_parse_and_update_mappings(map_key, values, mappings_struct) do
    map =
      values
      |> String.split("\r\n", trim: true)
      |> Enum.reduce(%{}, fn map_row, acc ->
        [destination_range_start, source_range_start, range_length] =
          map_row |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

        range_key = {source_range_start, source_range_start + range_length - 1}
        map_func = fn value -> value + (destination_range_start - source_range_start) end

        Map.put(acc, range_key, map_func)
      end)

    Map.put(mappings_struct, map_key, map)
  end

  def find_location_for_seed(seed, mappings_struct) do
    seed
    |> map_source_to_destination_value(mappings_struct.seed_to_soil_map)
    |> map_source_to_destination_value(mappings_struct.soil_to_fertilizer_map)
    |> map_source_to_destination_value(mappings_struct.fertilizer_to_water_map)
    |> map_source_to_destination_value(mappings_struct.water_to_light_map)
    |> map_source_to_destination_value(mappings_struct.light_to_temperature_map)
    |> map_source_to_destination_value(mappings_struct.temperature_to_humidity_map)
    |> map_source_to_destination_value(mappings_struct.humidity_to_location_map)
  end

  def map_source_to_destination_value(source_value, range_map) do
    result =
      Map.filter(range_map, fn {{range_start, range_end}, _} ->
        source_value >= range_start && source_value <= range_end
      end)

    if result == %{} do
      source_value
    else
      map_func = result |> Map.values() |> hd()
      map_func.(source_value)
    end
  end

  def create_range_of_seeds([seed, length]) do
    seed = seed |> String.to_integer()
    length = length |> String.to_integer()
    seed..(seed + length - 1) |> Enum.to_list()
  end
end
