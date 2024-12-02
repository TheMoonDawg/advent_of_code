defmodule Year2024Day2 do
  @behaviour Solution

  @test_input """
  7 6 4 2 1
  1 2 7 8 9
  9 7 6 2 1
  1 3 2 4 5
  8 6 4 4 1
  1 3 6 7 9
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  2
  """
  def solve_part_1(input) do
    input
    |> parse_input()
    |> Enum.count(fn report -> report_safe?(report, false) end)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  4
  """
  def solve_part_2(input) do
    input
    |> parse_input()
    |> Enum.count(fn report -> report_safe?(report, true) end)
  end

  defp report_safe?(report, use_dampener?) do
    {valid?, _, _} = check_report(report, use_dampener?)

    valid?
  end

  defp check_report(report, use_dampener?) do
    report
    |> Enum.reduce_while({true, nil, nil}, fn value, acc ->
      {_, last_value, order} = acc

      cond do
        # First run
        is_nil(last_value) ->
          {:cont, {true, value, nil}}

        # Second run
        is_nil(order) and value > last_value and safe_levels?(value, last_value) ->
          {:cont, {true, value, "asc"}}

        # Second run
        is_nil(order) and value < last_value and safe_levels?(last_value, value) ->
          {:cont, {true, value, "desc"}}

        order == "asc" and safe_levels?(value, last_value) ->
          {:cont, {true, value, order}}

        order == "desc" and safe_levels?(last_value, value) ->
          {:cont, {true, value, order}}

        use_dampener? ->
          {:halt, run_dampener(report)}

        true ->
          {:halt, {false, nil, nil}}
      end
    end)
  end

  defp safe_levels?(value, other_value), do: (value - other_value) in 1..3

  defp run_dampener(report) do
    report_length = length(report) - 1

    tolerated? =
      Enum.any?(0..report_length, fn index ->
        {valid?, _, _} =
          report
          |> List.delete_at(index)
          |> check_report(false)

        valid?
      end)

    if tolerated? do
      {true, nil, nil}
    else
      {false, nil, nil}
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn pair ->
      pair
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
