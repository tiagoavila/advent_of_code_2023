defmodule DaySixteenTest do
  use ExUnit.Case

  @tag skip: true
  test "DaySixteen - test part one" do
    assert File.read!("./inputs/day_sixteen/test_input.txt")
           |> String.split("\r\n", trim: true)
           |> DaySixteen.part_one() == 46
  end

  @tag skip: true
  test "DaySixteen - challenge part one" do
    assert File.read!("./inputs/day_sixteen/challenge_input.txt")
           |> String.split("\r\n", trim: true)
           |> DaySixteen.part_one()
           |> IO.inspect(label: "DaySixteen - challenge one")
  end

  @tag skip: true
  test "DaySixteen - test part two" do
    assert File.read!("./inputs/day_sixteen/test_input.txt")
           |> String.split("\r\n", trim: true)
           |> DaySixteen.part_two() == 51
  end

  @tag skip: true
  test "DaySixteen - challenge part two" do
    assert File.read!("./inputs/day_sixteen/challenge_input.txt")
           |> String.split("\r\n", trim: true)
           |> DaySixteen.part_two()
           |> IO.inspect(label: "day_sixteen - challenge two")
  end
end
