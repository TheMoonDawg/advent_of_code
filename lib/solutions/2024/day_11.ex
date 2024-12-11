defmodule Solutions.Year2024Day11 do
  @behaviour Solution

  @test_input "125 17"

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  55312
  """
  def solve_part_1(input) do
    stones = parse_input(input)

    for _x <- 1..25, reduce: stones do
      stones -> Enum.flat_map(stones, &transform_stone/1)
    end
    |> length()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  nil
  """
  def solve_part_2(input) do
    stones = parse_input(input)

    for x <- 1..75, reduce: stones do
      stones ->
        new_stones = Stream.flat_map(stones, &transform_stone/1)

        IO.inspect("Length for #{x} is #{length(new_stones)}")

        new_stones
    end
    |> length()
  end

  defp parse_input(input) do
    input
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp transform_stone(stone) do
    stone_str = to_string(stone)

    cond do
      stone == 0 ->
        1

      rem(String.length(stone_str), 2) == 0 ->
        {left, right} = String.split_at(stone_str, div(String.length(stone_str), 2))
        left_int = String.to_integer(left)
        right_int = String.to_integer(right)
        [left_int, right_int]

      true ->
        stone * 2024
    end
    |> List.wrap()
  end
end
