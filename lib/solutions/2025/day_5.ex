defmodule Solutions.Year2025Day5 do
  @behaviour Solution

  @test_input """
  3-5
  10-14
  16-20
  12-18

  1
  5
  8
  11
  17
  32
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  3
  """
  def solve_part_1(input) do
    {ranges, ingredient_ids} = parse_input(input)

    Enum.count(ingredient_ids, fn ingredient_id ->
      Enum.any?(ranges, fn range -> ingredient_id in range end)
    end)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  14
  """
  def solve_part_2(input) do
    {ranges, _} = parse_input(input)

    sorted_ranges =
      Enum.sort_by(ranges, fn range ->
        min.._//1 = range
        min
      end)

    sorted_ranges
    |> Enum.reduce([], fn range, acc -> flatten_ranges(acc, range) end)
    |> Enum.sum_by(&Range.size/1)
  end

  def parse_input(input) do
    {ranges, ingredient_ids} =
      input
      |> String.split("\n", trim: true)
      |> Enum.split_with(&String.contains?(&1, "-"))

    ranges =
      Enum.map(ranges, fn range ->
        [min, max] = String.split(range, "-")

        min_int = String.to_integer(min)
        max_int = String.to_integer(max)

        min_int..max_int
      end)

    ingredient_ids = Enum.map(ingredient_ids, &String.to_integer/1)

    {ranges, ingredient_ids}
  end

  defp flatten_ranges([], range), do: [range]

  defp flatten_ranges(ranges, range) do
    prev_index = length(ranges) - 1
    prev_min..prev_max//1 = prev_range = Enum.at(ranges, prev_index)
    _..max//1 = range

    cond do
      Range.disjoint?(prev_range, range) -> ranges ++ [range]
      max > prev_max -> List.replace_at(ranges, prev_index, prev_min..max)
      true -> ranges
    end
  end
end
