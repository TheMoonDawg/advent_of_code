defmodule Solutions.Year2024Day16 do
  @behaviour Solution

  @test_input """
  ###############
  #.......#....E#
  #.#.###.#.###.#
  #.....#.#...#.#
  #.###.#####.#.#
  #.#.#.......#.#
  #.#.#####.###.#
  #...........#.#
  ###.#.#####.#.#
  #...#.....#.#.#
  #.#.#.###.#.#.#
  #.....#...#.#.#
  #.###.#.#.#.#.#
  #S..#.....#...#
  ###############
  """

  @test_input2 """
  #################
  #...#...#...#..E#
  #.#.#.#.#.#.#.#.#
  #.#.#.#...#...#.#
  #.#.#.#.###.#.#.#
  #...#.#.#.....#.#
  #.#.#.#.#.#####.#
  #.#...#.#.#.....#
  #.#.#####.#.###.#
  #.#.#.......#...#
  #.#.###.#####.###
  #.#.#...#.....#.#
  #.#.#.#####.###.#
  #.#.#.........#.#
  #.#.#.#########.#
  #S#.............#
  #################
  """

  @test_input3 """
  #################
  #...#...#...#..E#
  #.#.#.#.#.#.#.#.#
  #.#.#.#...#...#.#
  #.#.#.#.###.#.#.#
  #...#.#.#.....#.#
  #.#.#.#...#####.#
  #.#.....#.#.....#
  #.#.##.##.#.###.#
  #.#.#.......#...#
  #.#.###.#####.###
  #.#.#...#.....#.#
  #.#.#.#####.###.#
  #.#.#.........#.#
  #.#.#.#########.#
  #S#.............#
  #################
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  7036
  """
  def solve_part_1(input) do
    {map, start_pos, _end_pos} = parse_input(@test_input3)
    {x, y} = start_pos

    map
    |> traverse_maze(:east, x, y, MapSet.new(), 0)
    |> Enum.min()
  end

  defp traverse_maze(map, direction, x, y, history, score) do
    {{x_offset, y_offset}, turns} = get_offsets(direction)

    IO.inspect(score)

    if map[x][y] == "E" do
      # if score == 7029 do
      #   IO.inspect(audit)
      #   IO.inspect(score)
      # end

      [score]
    else
      turns
      |> Enum.concat([{direction, {x_offset, y_offset}}])
      |> Enum.reject(fn {_, {d_x_offset, d_y_offset}} ->
        new_x = x + d_x_offset
        new_y = y + d_y_offset
        wall?(map, new_x, new_y) or MapSet.member?(history, {new_x, new_y})
      end)
      |> Enum.flat_map(fn {new_direction, {d_x_offset, d_y_offset}} ->
        score_addition = if(new_direction !== direction, do: 1001, else: 1)

        # new_audit =
        #   audit ++ [{new_direction, x + d_x_offset, y + d_y_offset, score + score_addition}]

        traverse_maze(
          map,
          new_direction,
          x + d_x_offset,
          y + d_y_offset,
          MapSet.put(history, {x, y}),
          score + score_addition
          # new_audit
        )
      end)
    end
  end

  defp get_offsets(direction) do
    north = {-1, 0}
    east = {0, 1}
    south = {1, 0}
    west = {0, -1}

    vertical_turns = [north: north, south: south]
    horizontal_turns = [west: west, east: east]

    case direction do
      :north -> {north, horizontal_turns}
      :east -> {east, vertical_turns}
      :south -> {south, horizontal_turns}
      :west -> {west, vertical_turns}
    end
  end

  defp wall?(map, x, y), do: map[x][y] == "#"

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
    |> Enum.reduce({%{}, nil, nil}, fn {row, r_index}, {row_map, start_pos, end_pos} ->
      {col_map, start_pos, end_pos} =
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({%{}, start_pos, end_pos}, fn {char, c_index}, acc ->
          {col_map, start_pos, end_pos} = acc
          start_pos = if(char == "S", do: {r_index, c_index}, else: start_pos)
          end_pos = if(char == "E", do: {r_index, c_index}, else: end_pos)

          {Map.put(col_map, c_index, char), start_pos, end_pos}
        end)

      {Map.put(row_map, r_index, col_map), start_pos, end_pos}
    end)
  end
end
