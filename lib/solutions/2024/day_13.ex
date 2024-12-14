defmodule Solutions.Year2024Day13 do
  @behaviour Solution

  @test_input """
  Button A: X+94, Y+34
  Button B: X+22, Y+67
  Prize: X=8400, Y=5400

  Button A: X+26, Y+66
  Button B: X+67, Y+21
  Prize: X=12748, Y=12176

  Button A: X+17, Y+86
  Button B: X+84, Y+37
  Prize: X=7870, Y=6450

  Button A: X+69, Y+23
  Button B: X+27, Y+71
  Prize: X=18641, Y=10279
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  480
  """
  def solve_part_1(input) do
    input
    |> parse_input(false)
    |> run_equations()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  875318608908
  """
  def solve_part_2(input) do
    input
    |> parse_input(true)
    |> run_equations()
  end

  defp parse_input(input, pad_prize?) do
    input
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn chunk ->
      button = ~r/X\+(?<x>\d+), Y\+(?<y>\d+)/
      prize = ~r/X=(?<x>\d+), Y=(?<y>\d+)/
      [button_a, button_b, prize_loc] = chunk

      button_a_matches = Regex.named_captures(button, button_a)
      button_b_matches = Regex.named_captures(button, button_b)
      prize_loc_matches = Regex.named_captures(prize, prize_loc)

      %{
        button_a: parse_matches(button_a_matches, false),
        button_b: parse_matches(button_b_matches, false),
        prize_loc: parse_matches(prize_loc_matches, pad_prize?)
      }
    end)
  end

  defp parse_matches(matches, pad_val?) do
    pad = if(pad_val?, do: 10_000_000_000_000, else: 0)
    x = String.to_integer(matches["x"]) + pad
    y = String.to_integer(matches["y"]) + pad

    {x, y}
  end

  defp run_equations(machines) do
    machines
    |> Enum.map(fn machine ->
      %{button_a: {a_x, a_y}, button_b: {b_x, b_y}, prize_loc: {p_x, p_y}} = machine

      a = Nx.tensor([[a_x, b_x], [a_y, b_y]], type: {:f, 64})
      b = Nx.tensor([p_x, p_y], type: {:f, 64})

      Nx.LinAlg.solve(a, b) |> Nx.to_list()
    end)
    |> Enum.filter(fn [x, y] ->
      abs(x - round(x)) < 0.01 and abs(y - round(y)) < 0.01
    end)
    |> Enum.map(fn [x, y] ->
      x = round(x)
      y = round(y)

      x * 3 + y
    end)
    |> Enum.sum()
  end
end
