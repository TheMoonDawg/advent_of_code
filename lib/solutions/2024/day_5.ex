defmodule Solutions.Year2024Day5 do
  @behaviour Solution

  @test_input """
  47|53
  97|13
  97|61
  97|47
  75|29
  61|13
  75|53
  29|13
  97|29
  53|29
  61|53
  97|53
  61|29
  47|13
  75|47
  97|75
  47|61
  75|61
  47|29
  75|13
  53|13

  75,47,61,53,29
  97,61,53,29,13
  75,29,13
  75,97,47,61,53
  61,13,29
  97,13,75,29,47
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  143
  """
  def solve_part_1(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.filter(&valid_update?(rules, &1))
    |> Enum.map(fn page_numbers ->
      index = div(length(page_numbers), 2)
      Enum.at(page_numbers, index)
    end)
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  123
  """
  def solve_part_2(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.reject(&valid_update?(rules, &1))
    |> Enum.map(fn invalid_update ->
      Enum.sort(invalid_update, fn num_1, num_2 ->
        not Enum.any?(rules, fn rule -> rule == [num_2, num_1] end)
      end)
    end)
    # |> IO.inspect(charlists: false)
    |> Enum.map(fn page_numbers ->
      index = div(length(page_numbers), 2)
      Enum.at(page_numbers, index)
    end)
    |> Enum.sum()
  end

  defp parse_input(input) do
    {rules, updates} =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce({[], []}, fn row, {rules, updates} ->
        if String.contains?(row, "|") do
          rule = String.split(row, "|") |> Enum.map(&String.to_integer/1)

          {[rule | rules], updates}
        else
          update = String.split(row, ",") |> Enum.map(&String.to_integer/1)

          {rules, [update | updates]}
        end
      end)

    {rules, updates}
  end

  defp valid_update?(rules, update) do
    rules
    |> Enum.all?(fn [page_1, page_2] ->
      pos_one = Enum.find_index(update, &(&1 == page_1))
      pos_two = Enum.find_index(update, &(&1 == page_2))
      is_nil(pos_one) or is_nil(pos_two) or pos_one <= pos_two
    end)
  end
end
