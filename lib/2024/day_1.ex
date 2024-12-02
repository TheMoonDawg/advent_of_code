defmodule Year2024Day1 do
  @behaviour Solution

  @test_input """
  3   4
  4   3
  2   5
  1   3
  3   9
  3   3
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  11
  """
  def solve_part_1(input) do
    %{list_one: list_one, list_two: list_two} = parse_input(input)

    list_length = length(list_one) - 1

    Enum.reduce(0..list_length, 0, fn index, acc ->
      value_one = Enum.at(list_one, index)
      value_two = Enum.at(list_two, index)

      acc + abs(value_one - value_two)
    end)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  31
  """
  def solve_part_2(input) do
    %{list_one: list_one, list_two: list_two} = parse_input(input)

    list_length = length(list_one) - 1

    Enum.reduce(0..list_length, 0, fn index, acc ->
      value = Enum.at(list_one, index)
      similarity_score = Enum.count(list_two, &(&1 == value))

      acc + value * similarity_score
    end)
  end

  def parse_input(input) do
    pairs =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn pair ->
        pair
        |> String.split("   ")
        |> Enum.map(&String.to_integer/1)
      end)

    %{
      list_one: parse_pair(pairs, 0),
      list_two: parse_pair(pairs, 1)
    }
  end

  defp parse_pair(pairs, index), do: pairs |> Enum.map(&Enum.at(&1, index)) |> Enum.sort()

  # def calculate_calibration(values) do
  #   values
  #   |> Enum.map(fn value ->
  #     first_digit = String.at(value, 0)
  #     last_digit = String.at(value, -1)

  #     String.to_integer(first_digit <> last_digit)
  #   end)
  #   |> Enum.sum()
  # end

  # defp replace_permutations(value) do
  #   Enum.reduce(get_permutations(), value, fn {k, v}, acc ->
  #     String.replace(acc, k, v)
  #   end)
  # end

  # defp replace_single_digits(value) do
  #   Enum.reduce(@single_digit_mapping, value, fn {k, v}, acc ->
  #     String.replace(acc, k, v)
  #   end)
  # end

  # defp get_permutations do
  #   Enum.reduce(@single_digit_mapping, %{}, fn a, acc ->
  #     permutations =
  #       @single_digit_mapping
  #       |> Map.delete(elem(a, 0))
  #       |> Enum.map(fn b -> get_permutation_key_value(a, b) end)
  #       |> Enum.reject(&is_nil/1)
  #       |> Map.new()

  #     Map.merge(acc, permutations)
  #   end)
  # end

  # defp get_permutation_key_value({ak, av}, {bk, bv}) do
  #   cond do
  #     String.last(bk) === String.first(ak) ->
  #       key = bk <> String.slice(ak, 1..-1)
  #       {key, bv <> av}

  #     String.last(ak) === String.first(bk) ->
  #       key = ak <> String.slice(bk, 1..-1)
  #       {key, av <> bv}

  #     true ->
  #       nil
  #   end
  # end
end
