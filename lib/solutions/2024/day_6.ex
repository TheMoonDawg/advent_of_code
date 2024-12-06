defmodule Solutions.Year2024Day6 do
  @behaviour Solution

  @test_input """
  ....#.....
  .........#
  ..........
  ..#.......
  .......#..
  ..........
  .#..^.....
  ........#.
  #.........
  ......#...
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  nil
  """
  def solve_part_1(input) do
    {map, {row, col}} = parse_input(input)

    positions = get_positions(map, row, col, :north, MapSet.new())

    MapSet.size(positions)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  nil
  """
  def solve_part_2(_input) do
    nil
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({%{}, nil}, fn {row, r_index}, {acc, pos} ->
      {row_map, pos} =
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({%{}, pos}, fn {col, c_index}, {acc, pos} ->
          pos =
            if col == "^" do
              {r_index, c_index}
            else
              pos
            end

          {Map.put(acc, c_index, col), pos}
        end)

      {Map.put(acc, r_index, row_map), pos}
    end)
  end

  defp get_positions(map, row, col, direction, positions) do
    {new_row, new_col} =
      case direction do
        :north -> {row - 1, col}
        :east -> {row, col + 1}
        :south -> {row + 1, col}
        :west -> {row, col - 1}
      end

    new_positions = MapSet.put(positions, {row, col})

    new_direction = get_new_direction(direction)

    cond do
      not in_bounds?(map, new_row, new_col) -> new_positions
      map[new_row][new_col] == "#" -> get_positions(map, row, col, new_direction, new_positions)
      true -> get_positions(map, new_row, new_col, direction, new_positions)
    end
  end

  defp in_bounds?(map, row, col) do
    {height, width} = get_bounds(map)

    row >= 0 and row < height and col >= 0 and col < width
  end

  defp get_bounds(map) do
    height = length(Map.keys(map))
    width = length(Map.keys(map[0]))

    {height, width}
  end

  defp get_new_direction(:north), do: :east
  defp get_new_direction(:east), do: :south
  defp get_new_direction(:south), do: :west
  defp get_new_direction(:west), do: :north
end
