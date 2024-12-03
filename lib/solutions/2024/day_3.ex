defmodule Solutions.Year2024Day3 do
  @behaviour Solution

  @test_input_one """
  xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
  """

  @test_input_two """
  xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input_one)})
  161
  """
  def solve_part_1(input) do
    input
    |> parse_muls(false)
    |> Enum.reduce(0, fn [num_one, num_two], acc ->
      acc + num_one * num_two
    end)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input_two)})
  48
  """
  def solve_part_2(input) do
    input
    |> parse_muls(true)
    |> Enum.reduce({true, 0}, fn match, acc ->
      {enabled?, sum} = acc

      case match do
        :start ->
          {true, sum}

        :stop ->
          {false, sum}

        [num_one, num_two] ->
          if enabled? do
            {enabled?, sum + num_one * num_two}
          else
            acc
          end
      end
    end)
    |> elem(1)
  end

  defp parse_muls(input, include_instructions?) do
    exp = "mul\\((\\d{1,3}),(\\d{1,3})\\)"
    instr_exp = "don't\\(\\)|do\\(\\)"

    if include_instructions? do
      Regex.compile!("#{exp}|#{instr_exp}")
    else
      Regex.compile!(exp)
    end
    |> Regex.scan(input)
    |> Enum.map(fn match ->
      [whole | captures] = match

      case whole do
        "do()" -> :start
        "don't()" -> :stop
        _ -> Enum.map(captures, &String.to_integer/1)
      end
    end)
  end
end
