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

  # @test_input """
  # #######
  # #...#.#
  # #.....#
  # #..OO@#
  # #..O..#
  # #.....#
  # #######

  # <vv<<^^<<^^
  # """

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

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  9021
  """
  def solve_part_2(input) do
    {map, directions, _robot_pos} = parse_input(input)
    {map, robot_pos} = create_bigger_map(map)

    {updated_map, _updated_robot_pos} =
      Enum.reduce(directions, {map, robot_pos}, fn direction, {map, robot_pos} ->
        resp = check_big_warehouse(map, direction, robot_pos)

        # draw_map(elem(resp, 0), direction, robot_pos != elem(resp, 1))

        resp
      end)

    updated_map
    |> Enum.map(fn {r_index, col_map} ->
      # Grab sum for the row
      Enum.reduce(col_map, 0, fn {c_index, char}, sum ->
        if char == "[" do
          sum + (100 * r_index + c_index)
        else
          sum
        end
      end)
    end)
    |> Enum.sum()
  end

  defp create_bigger_map(map) do
    map
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce({%{}, nil}, fn {r_index, col_map}, {row_map, robot_pos} ->
      {new_col_map, robot_pos} =
        col_map
        |> Map.to_list()
        |> Enum.sort_by(&elem(&1, 0))
        |> Enum.map(fn {_, char} ->
          case char do
            "#" -> "##"
            "O" -> "[]"
            "." -> ".."
            "@" -> "@."
          end
        end)
        |> Enum.join()
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({%{}, robot_pos}, fn {char, c_index}, {col_map, robot_pos} ->
          robot_pos = if(char == "@", do: {r_index, c_index}, else: robot_pos)

          {Map.put(col_map, c_index, char), robot_pos}
        end)

      {Map.put(row_map, r_index, new_col_map), robot_pos}
    end)
  end

  defp check_big_warehouse(map, direction, robot_pos) do
    {x, y} = robot_pos
    {x_offset, y_offset} = get_offset(direction)
    new_x = x + x_offset
    new_y = y + y_offset

    boxes = traverse_big_warehouse(map, direction, MapSet.new(), new_x, new_y)

    if boxes == false do
      {map, robot_pos}
    else
      new_robot_pos = {new_x, new_y}

      # Clear old boxes
      cleared_map =
        Enum.reduce(boxes, map, fn {_, b_x, b_y}, map ->
          put_in(map, [b_x, b_y], ".")
        end)

      # Write new boxes
      new_map =
        boxes
        |> Enum.reduce(cleared_map, fn {char, b_x, b_y}, map ->
          new_b_x = b_x + x_offset
          new_b_y = b_y + y_offset

          put_in(map, [new_b_x, new_b_y], char)
        end)
        |> put_in([x, y], ".")
        |> put_in([new_x, new_y], "@")

      {new_map, new_robot_pos}
    end
  end

  defp traverse_big_warehouse(map, direction, boxes, x, y) do
    {x_offset, y_offset} = get_offset(direction)

    cond do
      # First move - Found box
      MapSet.size(boxes) == 0 and map[x][y] in ["[", "]"] ->
        box_parts = get_box_parts(map[x][y], x, y)
        new_boxes = MapSet.union(boxes, box_parts)
        traverse_big_warehouse(map, direction, new_boxes, nil, nil)

      # First move - Wall
      MapSet.size(boxes) == 0 and map[x][y] == "#" ->
        false

      # First move - Clear space
      MapSet.size(boxes) == 0 and map[x][y] == "." ->
        boxes

      # Any box parts see a wall
      Enum.any?(boxes, fn {_, x, y} ->
        new_x = x + x_offset
        new_y = y + y_offset

        map[new_x][new_y] == "#"
      end) ->
        false

      # Any box parts see another box
      Enum.any?(boxes, fn {_, x, y} ->
        new_x = x + x_offset
        new_y = y + y_offset
        new_spot = map[new_x][new_y]

        new_spot in ["[", "]"] and MapSet.disjoint?(boxes, get_box_parts(new_spot, new_x, new_y))
      end) ->
        new_boxes =
          Enum.reduce(boxes, boxes, fn {_, x, y}, boxes ->
            new_x = x + x_offset
            new_y = y + y_offset
            new_spot = map[new_x][new_y]

            if new_spot in ["[", "]"] do
              MapSet.union(boxes, get_box_parts(new_spot, new_x, new_y))
            else
              boxes
            end
          end)

        traverse_big_warehouse(map, direction, new_boxes, nil, nil)

      # Boxes all found free space
      true ->
        boxes
    end
  end

  defp get_box_parts(char, x, y) do
    case char do
      "[" -> MapSet.new([{"[", x, y}, {"]", x, y + 1}])
      "]" -> MapSet.new([{"[", x, y - 1}, {"]", x, y}])
    end
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
      |> Enum.reduce({%{}, nil}, fn {row, r_index}, {row_map, robot_pos} ->
        {col_map, robot_pos} =
          row
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce({%{}, robot_pos}, fn {char, c_index}, {col_map, robot_pos} ->
            robot_pos = if(char == "@", do: {r_index, c_index}, else: robot_pos)

            {Map.put(col_map, c_index, char), robot_pos}
          end)

        {Map.put(row_map, r_index, col_map), robot_pos}
      end)

    directions = raw_directions |> Enum.join() |> String.graphemes()

    {map, directions, robot_pos}
  end

  defp get_offset(direction) do
    case direction do
      "^" -> {-1, 0}
      ">" -> {0, 1}
      "v" -> {1, 0}
      "<" -> {0, -1}
    end
  end

  def draw_map(map, direction, moved?) do
    IEx.Helpers.clear()

    if moved? do
      "#{direction} - Moved!"
    else
      "#{direction} - Did not move..."
    end
    |> IO.puts()

    map
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {_i, row} ->
      row
      |> Map.to_list()
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map(&elem(&1, 1))
      |> Enum.join()
      |> IO.puts()
    end)

    :timer.sleep(1000)
  end
end
