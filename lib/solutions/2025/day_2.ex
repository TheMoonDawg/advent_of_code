defmodule Solutions.Year2025Day2 do
  @behaviour Solution

  @test_input """
  11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  1227775554
  """
  def solve_part_1(input) do
    input
    |> parse_input()
    |> Task.async_stream(fn {min, max} ->
      min..max
      |> Enum.filter(&mirroed?/1)
      |> Enum.sum()
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  4174379265
  """
  def solve_part_2(input) do
    input
    |> parse_input()
    |> Task.async_stream(fn {min, max} ->
      min..max
      |> Enum.filter(fn val -> mirroed?(val) or sequence?(val) end)
      |> Enum.sum()
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn range ->
      [min, max] = String.split(range, "-")

      {String.to_integer(min), String.to_integer(max)}
    end)
  end

  defp mirroed?(val) do
    digits = Integer.digits(val)
    index = digits |> length() |> div(2)
    {front, back} = Enum.split(digits, index)

    front == back
  end

  defp sequence?(val) when val < 10, do: false

  defp sequence?(val) do
    digits = Integer.digits(val)
    max = digits |> length() |> div(2)

    Enum.any?(1..max, fn count ->
      digits |> Enum.chunk_every(count) |> Enum.uniq() |> length() == 1
    end)
  end
end
