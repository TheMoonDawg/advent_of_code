defmodule Solutions.Year2024Day4 do
  @behaviour Solution

  @test_input """
  MMMSXXMASM
  MSAMXMSMSA
  AMXSXMAAMM
  MSAMASMSMX
  XMASAMXAMM
  XXAMMXXAMA
  SMSMSASXSS
  SAXAMASAAA
  MAMMMXMMMM
  MXMXAXMASX
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  18
  """
  def solve_part_1(input) do
    puzzle = parse_input(input)

    {height, width} = get_bounds(puzzle)

    for row <- 0..(height - 1), column <- 0..(width - 1), reduce: 0 do
      acc -> acc + get_word_count(puzzle, row, column)
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
    |> Enum.map(&String.codepoints/1)
  end

  defp get_word_count(puzzle, row, column) do
    translations = [
      {-1, -1},
      {0, -1},
      {1, -1},
      {-1, 0},
      {1, 0},
      {-1, 1},
      {0, 1},
      {1, 1}
    ]

    Enum.count(translations, fn translate ->
      word_found?(puzzle, row, column, translate, "X")
    end)
  end

  defp word_found?(_puzzle, _row, _column, _translate, nil), do: true

  defp word_found?(puzzle, row, column, translate, letter) do
    next_letter =
      case letter do
        "X" -> "M"
        "M" -> "A"
        "A" -> "S"
        "S" -> nil
      end

    if letter_found?(puzzle, row, column, letter) do
      {row_offset, column_offset} = translate
      next_row = row + row_offset
      next_column = column + column_offset

      word_found?(puzzle, next_row, next_column, translate, next_letter)
    else
      false
    end
  end

  defp letter_found?(puzzle, row, column, letter) do
    if in_bounds?(puzzle, row, column) do
      puzzle
      |> Enum.at(row)
      |> Enum.at(column)
      |> Kernel.==(letter)
    else
      false
    end
  end

  defp in_bounds?(puzzle, row, column) do
    {height, width} = get_bounds(puzzle)

    row >= 0 and row < height and column >= 0 and column < width
  end

  defp get_bounds(puzzle) do
    height = length(puzzle)
    width = length(Enum.at(puzzle, 0))

    {height, width}
  end
end
