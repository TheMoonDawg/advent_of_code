defmodule Solver do
  def solve(year \\ Date.utc_today().year, day, part) do
    input = read_input(year, day)
    module = day_module(year, day)

    case part do
      1 -> module.solve_part_1(input)
      2 -> module.solve_part_2(input)
    end
  end

  def read_input(year, day) do
    File.read!("inputs/#{year}/day_#{day}.txt")
  end

  def day_module(year, day) do
    String.to_atom("Elixir.Solutions.Year#{year}Day#{day}")
  end
end
