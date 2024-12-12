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
    plots = parse_input(@test_input)
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
    [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]
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
