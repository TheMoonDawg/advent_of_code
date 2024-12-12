defmodule Solutions.Year2024Day11 do
  @behaviour Solution

  @test_input "125 17"

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  55312
  """
  def solve_part_1(input) do
    stones = parse_input(input)

    get_blinks(stones, 25)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  65601038650482
  """
  def solve_part_2(input) do
    stones = parse_input(input)

    get_blinks(stones, 75)
  end

  defp parse_input(input) do
    input
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn stone -> {stone, 1} end)
    |> Map.new()
  end

  defp get_blinks(stones, iterations) do
    for _x <- 1..iterations, reduce: stones do
      acc ->
        acc
        |> Map.to_list()
        |> Enum.reduce(%{}, fn {stone, count}, acc ->
          Enum.reduce(transform_stone(stone), acc, fn val, acc ->
            Map.update(acc, val, count, &(&1 + count))
          end)
        end)
    end
    |> Map.to_list()
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp transform_stone(stone) do
    cond do
      stone == 0 ->
        1

      rem(length(Integer.digits(stone)), 2) == 0 ->
        digits = Integer.digits(stone)
        {left_digits, right_digits} = Enum.split(digits, div(length(digits), 2))
        left = Enum.join(left_digits) |> String.to_integer()
        right = Enum.join(right_digits) |> String.to_integer()
        [left, right]

      true ->
        stone * 2024
    end
    |> List.wrap()
  end
end
