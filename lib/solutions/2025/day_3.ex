defmodule Solutions.Year2025Day3 do
  @behaviour Solution

  @test_input """
  987654321111111
  811111111111119
  234234234234278
  818181911112111
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  357
  """
  def solve_part_1(input) do
    input
    |> parse_input()
    |> Enum.sum_by(fn bank ->
      bank
      |> get_next_joltage_index([], 0, 2)
      |> convert_joltage_values()
    end)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  3121910778619
  """
  def solve_part_2(input) do
    input
    |> parse_input()
    |> Enum.sum_by(fn bank ->
      bank
      |> get_next_joltage_index([], 0, 12)
      |> convert_joltage_values()
    end)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp find_highest_joltage_index(bank, range_min, range_max) do
    bank
    |> Enum.with_index()
    |> Enum.slice(range_min..range_max//1)
    |> Enum.reduce({0, 0}, fn {joltage, index}, {h_joltage, _} = acc ->
      if joltage > h_joltage do
        {joltage, index}
      else
        acc
      end
    end)
  end

  defp get_next_joltage_index(bank, joltages, start_index, joltages_left) do
    {_, new_start_index} = val = find_highest_joltage_index(bank, start_index, -joltages_left)
    new_joltages = [val | joltages]

    if joltages_left > 1 do
      get_next_joltage_index(bank, new_joltages, new_start_index + 1, joltages_left - 1)
    else
      new_joltages
    end
  end

  defp convert_joltage_values(joltages) do
    joltages
    |> Enum.map(fn {joltage, _} -> to_string(joltage) end)
    |> Enum.reverse()
    |> Enum.join()
    |> String.to_integer()
  end
end
