defmodule Solutions.Year2025Day1 do
  @behaviour Solution

  @dial_start 50

  @test_input """
  L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82
  """

  # @test_input_2 """
  # L650
  # L30
  # R350
  # R3
  # R7
  # L1
  # """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  3
  """
  def solve_part_1(input) do
    input
    |> parse_input()
    |> Enum.reduce({@dial_start, 0}, fn rot, {dial, zero_count} ->
      {new_dial, _} = rotate(dial, rot)
      new_zero_count = if(new_dial == 0, do: zero_count + 1, else: zero_count)

      {new_dial, new_zero_count}
    end)
    |> elem(1)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  6
  """
  def solve_part_2(input) do
    input
    |> parse_input()
    |> Enum.reduce({@dial_start, 0}, fn rot, {dial, total_rotations} ->
      {new_dial, dial_rotations} = rotate(dial, rot)

      {new_dial, total_rotations + dial_rotations}
    end)
    |> elem(1)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      {dir, rot} = String.split_at(line, 1)
      {dir, String.to_integer(rot)}
    end)
  end

  defp rotate(dial, {"L", dist}) do
    new_dial = dial - rem(dist, 100)
    adjusted_dial = if(new_dial < 0, do: new_dial + 100, else: new_dial)

    total_rotations = div(dist, 100)
    zero_count = if(new_dial <= 0 and dial !== 0, do: 1, else: 0)

    {adjusted_dial, total_rotations + zero_count}
  end

  defp rotate(dial, {"R", dist}) do
    new_dial = dial + rem(dist, 100)
    adjusted_dial = if(new_dial > 99, do: new_dial - 100, else: new_dial)

    total_rotations = div(dist, 100)
    zero_count = if(new_dial > 99 and dial !== 0, do: 1, else: 0)

    {adjusted_dial, total_rotations + zero_count}
  end
end
