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
  41
  """
  def solve_part_1(input) do
    {map, {row, col}, _} = parse_input(input)

    positions = get_positions(map, row, col, :north, MapSet.new())

    MapSet.size(positions)
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

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  6
  """
  def solve_part_2(input) do
    # 252684.688 ms
    # {slow_time, res} = :timer.tc(fn -> slow_version(input) end)

    # 45809.441 ms
    {_fast_time, res} = :timer.tc(fn -> fast_version(input) end)

    # IO.inspect("Slow took #{slow_time / 1000} ms")
    # IO.inspect("Fast took #{fast_time / 1000} ms")

    res
  end

  # defp slow_version(input) do
  #   {starting_map, {starting_row, starting_col}, empty_positions} = parse_input(input)

  #   empty_positions
  #   |> MapSet.to_list()
  #   |> Enum.map(fn {row, col} ->
  #     map = put_in(starting_map[row][col], "#")
  #     path_loop?(map, starting_row, starting_col, :north, MapSet.new())
  #   end)
  #   |> Enum.filter(& &1)
  #   |> Enum.count()
  # end

  defp fast_version(input) do
    {starting_map, {starting_row, starting_col}, empty_positions} = parse_input(input)

    empty_positions
    |> MapSet.to_list()
    |> Task.async_stream(
      fn {row, col} ->
        map = put_in(starting_map[row][col], "#")
        path_loop?(map, starting_row, starting_col, :north, MapSet.new())
      end,
      max_concurrency: 10
    )
    |> Enum.filter(fn {:ok, loop?} -> loop? end)
    |> Enum.count()
  end

  defp path_loop?(map, row, col, direction, positions) do
    {new_row, new_col} =
      case direction do
        :north -> {row - 1, col}
        :east -> {row, col + 1}
        :south -> {row + 1, col}
        :west -> {row, col - 1}
      end

    position_key = {row, col, direction}

    new_positions = MapSet.put(positions, position_key)
    new_direction = get_new_direction(direction)

    cond do
      not in_bounds?(map, new_row, new_col) -> false
      MapSet.member?(positions, position_key) -> true
      map[new_row][new_col] == "#" -> path_loop?(map, row, col, new_direction, new_positions)
      true -> path_loop?(map, new_row, new_col, direction, new_positions)
    end
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(
      {%{}, nil, MapSet.new()},
      fn {row, r_index}, {acc, starting_position, empty_positions} ->
        {row_map, starting_position, empty_positions} =
          row
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(
            {%{}, starting_position, empty_positions},
            fn {col, c_index}, {acc, starting_position, empty_positions} ->
              starting_position =
                if col == "^" do
                  {r_index, c_index}
                else
                  starting_position
                end

              empty_positions =
                if col == "." do
                  MapSet.put(empty_positions, {r_index, c_index})
                else
                  empty_positions
                end

              {Map.put(acc, c_index, col), starting_position, empty_positions}
            end
          )

        {Map.put(acc, r_index, row_map), starting_position, empty_positions}
      end
    )
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
