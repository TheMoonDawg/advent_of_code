defmodule Solutions.Year2024Day10 do
  @behaviour Solution

  @test_input """
  89010123
  78121874
  87430965
  96549874
  45678903
  32019012
  01329801
  10456732
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  36
  """
  def solve_part_1(input) do
    {map, {height, width}} = parse_input(input)

    trail_heads = get_trail_heads(map, height, width)

    trail_heads
    |> Enum.map(fn {row, col} ->
      get_trail_peaks(map, row, col, 1, [])
      |> MapSet.new()
      |> MapSet.size()
    end)
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  81
  """
  def solve_part_2(input) do
    {map, {height, width}} = parse_input(input)

    trail_heads = get_trail_heads(map, height, width)

    trail_heads
    |> Enum.map(fn {row, col} ->
      length(get_trail_peaks(map, row, col, 1, []))
    end)
    |> Enum.sum()
  end

  defp parse_input(input) do
    rows = input |> String.split("\n", trim: true)
    columns = rows |> Enum.at(0) |> String.length()

    size = {length(rows), columns}

    map =
      rows
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, r_index}, acc ->
        cols =
          row
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.map(fn {col, index} -> {index, String.to_integer(col)} end)
          |> Map.new()

        Map.put(acc, r_index, cols)
      end)

    {map, size}
  end

  defp get_trail_heads(map, height, width) do
    for r <- 0..(height - 1), c <- 0..(width - 1), reduce: [] do
      acc ->
        if map[r][c] == 0 do
          [{r, c} | acc]
        else
          acc
        end
    end
  end

  defp get_trail_peaks(map, row, col, trail_number, peaks) do
    get_cardinal_offsets()
    |> Enum.map(fn {r_offset, c_offset} -> {row + r_offset, col + c_offset} end)
    |> Enum.filter(fn {row, col} -> map[row][col] == trail_number end)
    |> Enum.map(fn {row, col} ->
      if trail_number == 9 do
        [{row, col}]
      else
        get_trail_peaks(map, row, col, trail_number + 1, peaks)
      end
    end)
    |> Enum.reduce(peaks, fn list, acc ->
      acc ++ list
    end)
  end

  defp get_cardinal_offsets do
    [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]
  end
end
