defmodule Solutions.Year2024Day16 do
  @behaviour Solution

  @max_limit 2_000_000_000

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

  # @test_input2 """
  # #################
  # #...#...#...#..E#
  # #.#.#.#.#.#.#.#.#
  # #.#.#.#...#...#.#
  # #.#.#.#.###.#.#.#
  # #...#.#.#.....#.#
  # #.#.#.#.#.#####.#
  # #.#...#.#.#.....#
  # #.#.#####.#.###.#
  # #.#.#.......#...#
  # #.#.###.#####.###
  # #.#.#...#.....#.#
  # #.#.#.#####.###.#
  # #.#.#.........#.#
  # #.#.#.#########.#
  # #S#.............#
  # #################
  # """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  7036
  """
  def solve_part_1(input) do
    {map, start_pos, end_pos} = parse_input(input)
    graph = create_graph(map)

    queue =
      graph
      |> Map.keys()
      |> Enum.reject(&(&1 == start_pos))
      |> Enum.map(&{&1, @max_limit, nil})
      |> Enum.concat([{start_pos, 0, :east}])
      |> Enum.sort_by(&elem(&1, 1))

    distances =
      graph
      |> Map.keys()
      |> Enum.map(&{&1, @max_limit})
      |> Map.new()
      |> Map.put(start_pos, 0)

    final_distances = traverse_graph(graph, queue, distances)

    final_distances[end_pos]
  end

  defp traverse_graph(_graph, [], distances), do: distances

  defp traverse_graph(graph, queue, distances) do
    {{vertex, vertex_distance, direction}, popped_queue} = List.pop_at(queue, 0)

    # We've already traversed this
    if distances[vertex] < vertex_distance do
      traverse_graph(graph, popped_queue, distances)
    else
      {new_queue, new_distances} =
        graph[vertex]
        |> Enum.reduce({popped_queue, distances}, fn edge, {queue, distances} ->
          {weight, new_direction} = get_weight(vertex, edge, direction)

          new_distance = vertex_distance + weight

          if new_distance < distances[edge] do
            new_queue = push(queue, edge, new_distance, new_direction)
            new_distances = Map.put(distances, edge, new_distance)

            {new_queue, new_distances}
          else
            {queue, distances}
          end
        end)

      traverse_graph(graph, new_queue, new_distances)
    end
  end

  defp get_weight({v_x, v_y}, {e_x, e_y}, direction) do
    north = {-1, 0}
    east = {0, 1}
    south = {1, 0}
    west = {0, -1}

    edge_direction = {e_x - v_x, e_y - v_y}

    cond do
      # Moving north
      direction == :north and edge_direction == north -> {1, :north}
      direction == :north and edge_direction == west -> {1001, :west}
      direction == :north and edge_direction == east -> {1001, :east}
      direction == :north and edge_direction == south -> {2001, :south}
      # Moving east
      direction == :east and edge_direction == north -> {1001, :north}
      direction == :east and edge_direction == west -> {2001, :west}
      direction == :east and edge_direction == east -> {1, :east}
      direction == :east and edge_direction == south -> {1001, :south}
      # Moving south
      direction == :south and edge_direction == north -> {2001, :north}
      direction == :south and edge_direction == west -> {1001, :west}
      direction == :south and edge_direction == east -> {1001, :east}
      direction == :south and edge_direction == south -> {1, :south}
      # Moving west
      direction == :west and edge_direction == north -> {1001, :north}
      direction == :west and edge_direction == west -> {1, :west}
      direction == :west and edge_direction == east -> {2001, :east}
      direction == :west and edge_direction == south -> {1001, :south}
    end
  end

  def push(queue, vertex, distance, direction) do
    [{vertex, distance, direction} | queue]
    |> Enum.sort_by(&elem(&1, 1))
  end

  defp create_graph(map) do
    Enum.reduce(map, %{}, fn {r_index, row}, graph ->
      Enum.reduce(row, graph, fn {c_index, char}, graph ->
        if char in [".", "S", "E"] do
          surrounding = get_surrounding_vertices(map, r_index, c_index)
          Map.put(graph, {r_index, c_index}, surrounding)
        else
          graph
        end
      end)
    end)
  end

  defp get_surrounding_vertices(map, x, y) do
    offsets = [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]

    vertices =
      offsets
      |> Enum.filter(fn {x_offset, y_offset} ->
        map[x + x_offset][y + y_offset] in [".", "S", "E"]
      end)
      |> Enum.map(fn {x_offset, y_offset} ->
        {x + x_offset, y + y_offset}
      end)

    vertices
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
