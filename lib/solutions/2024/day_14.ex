defmodule Solutions.Year2024Day14 do
  @behaviour Solution

  @test_input """
  p=0,4 v=3,-3
  p=6,3 v=-1,-3
  p=10,3 v=-1,2
  p=2,0 v=2,-1
  p=0,0 v=1,3
  p=3,0 v=-2,-2
  p=7,6 v=-1,-3
  p=3,0 v=-1,-2
  p=9,3 v=2,3
  p=7,3 v=-1,2
  p=2,4 v=2,-3
  p=9,5 v=-3,-3
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)}, {11, 7})
  12
  """
  def solve_part_1(input, grid_size \\ {101, 103}) do
    # grid_size = {11, 7}
    {width, height} = grid_size

    input
    |> parse_input()
    |> Enum.reduce(%{}, fn robot, acc ->
      {final_x, final_y} =
        for _ <- 1..100, reduce: robot.position do
          {x, y} ->
            {x_offset, y_offset} = robot.velocity
            new_x = get_coord(x, x_offset, width)
            new_y = get_coord(y, y_offset, height)

            {new_x, new_y}
        end

      quadrant =
        cond do
          final_x < div(width, 2) and final_y < div(height, 2) -> :quadrant_1
          final_x > div(width, 2) and final_y < div(height, 2) -> :quadrant_2
          final_x < div(width, 2) and final_y > div(height, 2) -> :quadrant_3
          final_x > div(width, 2) and final_y > div(height, 2) -> :quadrant_4
          true -> nil
        end

      if is_nil(quadrant) do
        acc
      else
        Map.update(acc, quadrant, 1, &(&1 + 1))
      end
    end)
    |> Map.values()
    |> Enum.product()
  end

  defp get_coord(coord, offset, size) do
    new_coord = coord + offset

    cond do
      new_coord < 0 -> new_coord + size
      new_coord >= size -> new_coord - size
      true -> new_coord
    end
  end

  @doc """
  Part 2, but not testable!
  """
  def solve_part_2(input) do
    grid_size = {101, 103}
    robots = parse_input(input)
    {width, height} = grid_size

    base_map =
      for x <- 0..(width - 1), y <- 0..(height - 1), reduce: %{} do
        acc -> Map.update(acc, y, %{x => " "}, &Map.put(&1, x, " "))
      end

    for x <- 1..1_000_000, reduce: robots do
      acc ->
        new_robots =
          Enum.map(acc, fn robot ->
            {x, y} = robot.position
            {x_offset, y_offset} = robot.velocity
            new_x = get_coord(x, x_offset, width)
            new_y = get_coord(y, y_offset, height)

            Map.put(robot, :position, {new_x, new_y})
          end)

        draw_map(base_map, new_robots, x)

        new_robots
    end

    nil
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      pos = ~r/p=(?<x>\d+),(?<y>\d+)/
      vel = ~r/v=(?<x>-?\d+),(?<y>-?\d+)/

      position = Regex.named_captures(pos, row)
      velocity = Regex.named_captures(vel, row)

      %{
        position: {String.to_integer(position["x"]), String.to_integer(position["y"])},
        velocity: {String.to_integer(velocity["x"]), String.to_integer(velocity["y"])}
      }
    end)
  end

  defp draw_map(map, robots, seconds) do
    new_map =
      Enum.reduce(robots, map, fn robot, acc_map ->
        {x, y} = robot.position
        Map.update!(acc_map, x, &Map.put(&1, y, "O"))
      end)

    robot_positions =
      robots
      |> Enum.map(& &1.position)
      |> MapSet.new()

    maybe_tree? =
      Enum.any?(robot_positions, fn {x, y} ->
        surrounding_offsets = [
          {-1, 0},
          {0, -1},
          {1, 0},
          {0, 1},
          {-1, -1},
          {1, 1},
          {-1, 1},
          {1, -1}
        ]

        matches? =
          Enum.all?(surrounding_offsets, fn {x_offset, y_offset} ->
            MapSet.member?(robot_positions, {x + x_offset, y + y_offset})
          end)

        if(matches?, do: IO.inspect({x, y}))

        matches?
      end)

    if maybe_tree? do
      IO.puts("------------------------------")
      IO.puts("Map for #{seconds} seconds")
      IO.puts("------------------------------")

      new_map
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

      IO.gets("Is this a Christmas tree...? (Press Enter to try again):")
    end
  end
end
