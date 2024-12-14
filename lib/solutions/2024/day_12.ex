defmodule Solutions.Year2024Day12 do
  @behaviour Solution

  @test_input """
  RRRRIICCFF
  RRRRIICCCF
  VVRRRCCFFF
  VVRCCCJFFF
  VVVVCJJCFE
  VVIVCCJJEE
  VVIIICJJEE
  MIIIIIJJEE
  MIIISIJEEE
  MMMISSJEEE
  """

  # @test_input2 """
  # OOOOO
  # OXOXO
  # OOOOO
  # OXOXO
  # OOOOO
  # """

  # @test_input3 """
  # AAAA
  # BBCD
  # BBCC
  # EEEC
  # """

  # @test_input4 """
  # EEEEE
  # EXXXX
  # EEEEE
  # EXXXX
  # EEEEE
  # """

  # @test_input5 """
  # AAAAAA
  # AAABBA
  # AAABBA
  # ABBAAA
  # ABBAAA
  # AAAAAA
  # """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  1930
  """
  def solve_part_1(input) do
    plots = parse_input(input)
    {height, width} = get_bounds(plots)

    {regions, _} =
      for row <- 0..(height - 1), col <- 0..(width - 1), reduce: {[], MapSet.new()} do
        {regions, plotted_points} = acc ->
          if MapSet.member?(plotted_points, {row, col}) do
            acc
          else
            region_plots = create_region(plots, row, col)
            {[region_plots | regions], MapSet.union(plotted_points, region_plots)}
          end
      end

    regions
    |> Enum.map(fn region ->
      area = MapSet.size(region)
      perimeter = get_perimeter(region)

      area * perimeter
    end)
    |> Enum.sum()
  end

  defp get_perimeter(region) do
    region
    |> Enum.map(fn {row, col} ->
      get_cardinal_offsets()
      |> Map.values()
      |> Enum.map(fn {r_offset, c_offset} -> {row + r_offset, col + c_offset} end)
      |> Enum.reject(&MapSet.member?(region, &1))
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  1206
  """
  def solve_part_2(input) do
    plots = parse_input(input)
    {height, width} = get_bounds(plots)

    {regions, _} =
      for row <- 0..(height - 1), col <- 0..(width - 1), reduce: {[], MapSet.new()} do
        {regions, plotted_points} = acc ->
          if MapSet.member?(plotted_points, {row, col}) do
            acc
          else
            region_plots = create_region(plots, row, col)
            {[region_plots | regions], MapSet.union(plotted_points, region_plots)}
          end
      end

    regions
    |> Enum.map(fn region ->
      area = MapSet.size(region)
      sides = get_sides(region)

      area * sides
    end)
    |> Enum.sum()
  end

  defp get_sides(region) do
    region
    |> Enum.reject(fn {row, col} ->
      # Toss out any non-edge vertices
      get_cardinal_offsets()
      |> Map.values()
      |> Enum.map(fn {r_offset, c_offset} -> {row + r_offset, col + c_offset} end)
      |> Enum.all?(&MapSet.member?(region, &1))
    end)
    |> Enum.reduce(MapSet.new(), fn {row, col}, acc ->
      # Filter down to cardinal direction edges
      get_cardinal_offsets()
      |> Enum.reject(fn {_direction, {r_offset, c_offset}} ->
        coords = {row + r_offset, col + c_offset}
        MapSet.member?(region, coords)
      end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.reduce(acc, fn direction, lines ->
        line_points = traverse_sides(region, row, col, direction, MapSet.new())

        MapSet.put(lines, {direction, line_points})
      end)
    end)
    |> MapSet.size()
  end

  defp traverse_sides(region, row, col, direction, line_points) do
    {r_offset, c_offset} = get_cardinal_offsets()[direction]

    cond do
      # Already traversed this path
      MapSet.member?(line_points, {row, col}) ->
        line_points

      # Not in region
      not MapSet.member?(region, {row, col}) ->
        line_points

      # End of line
      MapSet.member?(region, {row + r_offset, col + c_offset}) ->
        line_points

      true ->
        new_line_points = MapSet.put(line_points, {row, col})

        case direction do
          :north -> [{0, -1}, {0, 1}]
          :east -> [{-1, 0}, {1, 0}]
          :south -> [{0, -1}, {0, 1}]
          :west -> [{-1, 0}, {1, 0}]
        end
        |> Enum.reduce(new_line_points, fn {r_offset, c_offset}, line_points ->
          traverse_sides(region, row + r_offset, col + c_offset, direction, line_points)
        end)
    end
  end

  defp parse_input(input) do
    plots =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, r_index}, acc ->
        col_map =
          row
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {col, c_index}, acc ->
            Map.put(acc, c_index, col)
          end)

        Map.put(acc, r_index, col_map)
      end)

    plots
  end

  defp create_region(plots, row, col) do
    traverse_region(plots, row, col, plots[row][col], MapSet.new())
  end

  defp traverse_region(plots, row, col, region, region_plots) do
    new_region_plots = MapSet.put(region_plots, {row, col})

    get_cardinal_offsets()
    |> Map.values()
    |> Enum.map(fn {r_offset, c_offset} -> {row + r_offset, col + c_offset} end)
    |> Enum.filter(fn {row, col} ->
      plots[row][col] == region and not MapSet.member?(region_plots, {row, col}) and
        in_bounds?(plots, row, col)
    end)
    |> Enum.reduce(new_region_plots, fn {row, col}, acc ->
      traverse_region(plots, row, col, region, acc)
    end)
  end

  defp get_cardinal_offsets do
    %{
      north: {-1, 0},
      east: {0, 1},
      south: {1, 0},
      west: {0, -1}
    }
  end

  defp get_bounds(plots) do
    height = Map.keys(plots) |> length()
    width = Map.keys(plots[0]) |> length()

    {height, width}
  end

  defp in_bounds?(plots, row, col) do
    {height, width} = get_bounds(plots)

    row >= 0 and row < height and col >= 0 and col < width
  end
end
