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
  3749
  """
  def solve_part_1(input) do
    input
    |> parse_input()
    |> Enum.filter(&valid_equation?(&1, ["+", "*"]))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  11387
  """
  def solve_part_2(input) do
    input
    |> parse_input()
    |> Enum.filter(&valid_equation?(&1, ["+", "*", "||"]))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
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

  defp valid_equation?({sum, vals}, operators) do
    operator_perms = shuffle(operators, length(vals) - 1)

    Enum.any?(operator_perms, fn operators ->
      test_sum =
        vals
        |> Enum.with_index()
        |> Enum.reduce(0, fn {val, index}, acc ->
          if index == 0 do
            val
          else
            compute(acc, val, Enum.at(operators, index - 1))
          end
        end)

      test_sum == sum
    end)
  end

  defp shuffle(_, 0), do: [[]]

  defp shuffle(list, i) do
    for x <- list, y <- shuffle(list, i - 1), do: [x | y]
  end

  defp compute(a, b, "+"), do: a + b
  defp compute(a, b, "*"), do: a * b
  defp compute(a, b, "||"), do: (to_string(a) <> to_string(b)) |> String.to_integer()
end
