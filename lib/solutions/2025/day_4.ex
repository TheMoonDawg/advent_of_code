defmodule Solutions.Year2025Day4 do
  @behaviour Solution

  @test_input """
  ..@@.@@@@.
  @@@.@.@.@@
  @@@@@.@.@@
  @.@@@@..@.
  @@.@@@@.@@
  .@@@@@@@.@
  .@.@.@.@@@
  @.@@@.@@@@
  .@@@@@@@@.
  @.@.@@@.@.
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  13
  """
  def solve_part_1(input) do
    map = parse_input(input)

    Enum.count(map, fn {{x_index, y_index}, char} ->
      paper_accessible?(map, x_index, y_index, char)
    end)
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  43
  """
  def solve_part_2(input) do
    map = parse_input(input)

    remove_paper(map, 0)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y_index} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x_index} ->
        {{x_index, y_index}, char}
      end)
    end)
    |> Map.new()
  end

  defp paper_accessible?(_, _, _, "."), do: false

  defp paper_accessible?(map, x_index, y_index, _) do
    Enum.count(
      [
        {x_index + 1, y_index - 1},
        {x_index + 1, y_index},
        {x_index + 1, y_index + 1},
        {x_index, y_index - 1},
        {x_index, y_index + 1},
        {x_index - 1, y_index - 1},
        {x_index - 1, y_index},
        {x_index - 1, y_index + 1}
      ],
      fn coords -> map[coords] == "@" end
    )
    |> Kernel.<(4)
  end

  defp remove_paper(map, rolls_removed) do
    removed_paper_map =
      map
      |> Enum.filter(fn {{x_index, y_index}, char} ->
        paper_accessible?(map, x_index, y_index, char)
      end)
      |> Enum.map(fn {{x_index, y_index}, _} -> {{x_index, y_index}, "."} end)
      |> Map.new()

    if Enum.empty?(removed_paper_map) do
      rolls_removed
    else
      new_map = Map.merge(map, removed_paper_map)
      new_rolls_removed = rolls_removed + map_size(removed_paper_map)

      remove_paper(new_map, new_rolls_removed)
    end
  end
end
