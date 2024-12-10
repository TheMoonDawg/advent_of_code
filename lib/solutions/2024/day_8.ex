defmodule Solutions.Year2024Day8 do
  @behaviour Solution

  @test_input """
  ............
  ........0...
  .....0......
  .......0....
  ....0.......
  ......A.....
  ............
  ............
  ........A...
  .........A..
  ............
  ............
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  14
  """
  def solve_part_1(input) do
    {antennas, size} = parse_input(input)

    antennas
    |> Enum.reduce(MapSet.new(), fn {_freq, vertices}, acc ->
      vertices_list = MapSet.to_list(vertices)
      vertices_size = length(vertices_list) - 1

      for a <- 0..vertices_size, b <- 0..vertices_size, reduce: MapSet.new() do
        acc ->
          vertex = Enum.at(vertices_list, a)
          {row_a, col_a} = vertex
          {row_b, col_b} = Enum.at(vertices_list, b)

          offset = {row_a - row_b, col_a - col_b}

          antinodes =
            [calculate_antinode(vertex, offset, false), calculate_antinode(vertex, offset, true)]
            |> Enum.filter(fn antinode ->
              {row, col} = antinode

              not MapSet.member?(vertices, antinode) and in_bounds?(size, row, col)
            end)
            |> MapSet.new()

          MapSet.union(acc, antinodes)
      end
      |> MapSet.union(acc)
    end)
    |> MapSet.size()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  34
  """
  def solve_part_2(input) do
    {antennas, size} = parse_input(input)

    antennas
    |> Enum.reduce(MapSet.new(), fn {_freq, vertices}, acc ->
      vertices_list = MapSet.to_list(vertices)
      vertices_size = length(vertices_list) - 1

      for a <- 0..vertices_size, b <- 0..vertices_size, reduce: MapSet.new() do
        acc ->
          vertex = Enum.at(vertices_list, a)
          {row_a, col_a} = vertex
          {row_b, col_b} = Enum.at(vertices_list, b)

          offset = {row_a - row_b, col_a - col_b}

          pos_antinodes = calculate_resonant_antinodes(size, vertex, offset, false, MapSet.new())
          neg_antinodes = calculate_resonant_antinodes(size, vertex, offset, true, MapSet.new())

          acc
          |> MapSet.union(pos_antinodes)
          |> MapSet.union(neg_antinodes)
      end
      |> MapSet.union(acc)
    end)
    |> MapSet.size()
  end

  defp calculate_resonant_antinodes(_, _, {0, 0}, _, _), do: MapSet.new()

  defp calculate_resonant_antinodes(size, vertex, offset, inverse?, antinodes) do
    next_antinode = calculate_antinode(vertex, offset, inverse?)
    {row, col} = next_antinode

    if in_bounds?(size, row, col) do
      new_antinotes = MapSet.put(antinodes, next_antinode)
      calculate_resonant_antinodes(size, next_antinode, offset, inverse?, new_antinotes)
    else
      antinodes
    end
  end

  defp parse_input(input) do
    rows = input |> String.split("\n", trim: true)
    columns = rows |> Enum.at(0) |> String.length()

    size = {length(rows), columns}

    antennas =
      rows
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, r_index}, points ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(points, fn {char, c_index}, points ->
          if char != "." do
            vertex = {r_index, c_index}

            Map.update(points, char, MapSet.new([vertex]), fn vertices ->
              MapSet.put(vertices, vertex)
            end)
          else
            points
          end
        end)
      end)

    {antennas, size}
  end

  defp calculate_antinode({row, col}, {o_row, o_col}, false), do: {row + o_row, col + o_col}
  defp calculate_antinode({row, col}, {o_row, o_col}, true), do: {row - o_row, col - o_col}

  defp in_bounds?({rows, cols}, row, col) do
    row >= 0 and row < rows and col >= 0 and col < cols
  end
end
