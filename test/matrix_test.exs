defmodule MatrixTest do
  use ExUnit.Case

  test "Transpose Matrix" do
    input = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]

    expected = [
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9]
    ]

    assert Matrix.transpose(input) == expected

    input2 = [
      [1, 2, 3],
      [4, 5, 6]
    ]

    expected2 = [
      [1, 4],
      [2, 5],
      [3, 6]
    ]

    assert Matrix.transpose(input2) == expected2
  end
end
