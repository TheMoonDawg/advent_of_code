defmodule Solutions.Year2024Day7 do
  @behaviour Solution

  @test_input """
  190: 10 19
  3267: 81 40 27
  83: 17 5
  156: 15 6
  7290: 6 8 6 15
  161011: 16 10 13
  192: 17 8 14
  21037: 9 7 18 13
  292: 11 6 16 20
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  nil
  """
  def solve_part_1(_input) do
    equations = parse_input(@test_input)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  nil
  """
  def solve_part_2(_input) do
    nil
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [sum, vals] = String.split(row, ": ")
      sum_int = String.to_integer(sum)
      val_ints = vals |> String.split(" ") |> Enum.map(&String.to_integer/1)

      {sum_int, val_ints}
    end)
  end
end
