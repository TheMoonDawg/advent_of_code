defmodule Solutions.Year2024Day15 do
  @behaviour Solution

  @test_input """
  ##########
  #..O..O.O#
  #......O.#
  #.OO..O.O#
  #..O@..O.#
  #O#..O...#
  #O..O..O.#
  #.OO.O.OO#
  #....O...#
  ##########

  <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
  vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
  ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
  <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
  ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
  ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
  >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
  <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
  ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
  v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  10092
  """
  def solve_part_1(input) do
    {map, directions, robot_pos} = parse_input(input)

    {updated_map, _updated_robot_pos} =
      Enum.reduce(directions, {map, robot_pos}, fn direction, {map, robot_pos} ->
        check_warehouse(map, direction, robot_pos)
      end)

    updated_map
    |> Enum.map(fn {r_index, col_map} ->
      # Grab sum for the row
      Enum.reduce(col_map, 0, fn {c_index, char}, sum ->
        if char == "O" do
          sum + (100 * r_index + c_index)
        else
          sum
        end
      end)
    end)
    |> Enum.sum()
  end

  defp check_warehouse(map, direction, robot_pos) do
    {x, y} = robot_pos
    {x_offset, y_offset} = get_offset(direction)
    new_x = x + x_offset
    new_y = y + y_offset

    boxes = traverse_warehouse(map, direction, MapSet.new(), new_x, new_y)

    if boxes == false do
      {map, robot_pos}
    else
      new_robot_pos = {new_x, new_y}

      # Clear old boxes
      cleared_map =
        Enum.reduce(boxes, map, fn {b_x, b_y}, map ->
          put_in(map, [b_x, b_y], ".")
        end)

      # Write new boxes
      new_map =
        boxes
        |> Enum.reduce(cleared_map, fn {b_x, b_y}, map ->
          new_b_x = b_x + x_offset
          new_b_y = b_y + y_offset

          put_in(map, [new_b_x, new_b_y], "O")
        end)
        |> put_in([x, y], ".")
        |> put_in([new_x, new_y], "@")

      {new_map, new_robot_pos}
    end
  end

  defp traverse_warehouse(map, direction, boxes, x, y) do
    {x_offset, y_offset} = get_offset(direction)

    cond do
      map[x][y] == "#" ->
        false

      map[x][y] == "." ->
        boxes

      map[x][y] == "O" ->
        new_boxes = MapSet.put(boxes, {x, y})
        new_x = x + x_offset
        new_y = y + y_offset
        traverse_warehouse(map, direction, new_boxes, new_x, new_y)
    end
  end

  defp get_offset(direction) do
    case direction do
      "^" -> {-1, 0}
      ">" -> {0, 1}
      "v" -> {1, 0}
      "<" -> {0, -1}
    end
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  nil
  """
  def solve_part_2(_input) do
    nil
  end

  defp parse_input(input) do
    {raw_map, raw_directions} =
      input
      |> String.split("\n", trim: true)
      |> Enum.split_with(fn row ->
        regex = ~r/^[#O.@]+$/

        Regex.match?(regex, row)
      end)

    {map, robot_pos} =
      raw_map
      |> Enum.with_index()
      |> Enum.reduce({%{}, nil}, fn {row, r_index}, {acc, robot_pos} ->
        {col_map, robot_pos} =
          row
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce({%{}, robot_pos}, fn {char, c_index}, {acc, robot_pos} ->
            robot_pos = if(char == "@", do: {r_index, c_index}, else: robot_pos)

            {Map.put(acc, c_index, char), robot_pos}
          end)

        {Map.put(acc, r_index, col_map), robot_pos}
      end)

    directions = raw_directions |> Enum.join() |> String.graphemes()

    {map, directions, robot_pos}
  end
end
