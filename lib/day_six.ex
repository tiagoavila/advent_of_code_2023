defmodule DaySix do
	def part_one(input) do
		input
		|> parse_content()
		|> Enum.reduce(1, fn {holding_time, distance}, acc ->
			count_holding_time_to_beat_record(holding_time, distance) * acc
		end)
	end

	def count_holding_time_to_beat_record(race_time, distance_to_beat) do
		0..race_time
		|> Enum.reduce_while(0, fn holding_time, acc ->
			distance_reached = calculate_distance(holding_time, race_time)
			if distance_reached > distance_to_beat do
				number_of_fails_for_race = acc * 2
				{:halt, race_time + 1 - number_of_fails_for_race}
			else
				{:cont, acc + 1}
			end
		end)
	end

	def calculate_distance(holding_time, race_time) do
		# For each whole millisecond you spend at the beginning of the race holding down
		# the button, the boat's speed increases by one millimeter per millisecond.

		milliseconds_to_move = race_time - holding_time
		speed_millimeters_per_millisecond = holding_time

		speed_millimeters_per_millisecond * milliseconds_to_move
	end

	defp parse_content(content) do
      content
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ~r/\s+/, trim: true) |> tl())
			|> Enum.zip_with(fn [time, distance] ->
				{String.to_integer(time), String.to_integer(distance)}
			end)
  end

	def part_two(input) do

	end
end
