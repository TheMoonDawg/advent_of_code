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
  nil
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
  iex> solve_part_2(#{inspect(@test_input)})
  nil
  """
  def solve_part_2(_input) do
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
end
