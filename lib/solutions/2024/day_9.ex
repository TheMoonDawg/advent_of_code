defmodule Solutions.Year2024Day9 do
  @behaviour Solution

  @test_input "2333133121414131402"

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  1928
  """
  def solve_part_1(input) do
    disk_map = parse_input(input)

    disk_map_size = map_size(disk_map) - 1

    IO.inspect("Moving file blocks...")

    updated_disk_map =
      Enum.reduce_while(0..disk_map_size, disk_map, fn index, acc ->
        if acc[index] == "." do
          swap_blocks(acc, index)
        else
          {:cont, acc}
        end
      end)

    IO.inspect("done!")

    IO.inspect("Calculating checksum...")

    checksum =
      Enum.reduce_while(0..disk_map_size, 0, fn index, acc ->
        if updated_disk_map[index] == "." do
          {:halt, acc}
        else
          val = String.to_integer(updated_disk_map[index])

          {:cont, acc + index * val}
        end
      end)

    IO.inspect("done!")

    checksum
  end

  defp swap_blocks(disk_map, index) do
    disk_map_size = map_size(disk_map) - 1

    rear_index =
      Enum.find(disk_map_size..0, fn rear_index ->
        disk_map[rear_index] != "."
      end)

    if rear_index < index do
      {:halt, disk_map}
    else
      {:cont,
       disk_map
       |> Map.put(index, disk_map[rear_index])
       |> Map.put(rear_index, ".")}
    end
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  2858
  """
  def solve_part_2(_input) do
    disk_map = parse_input(@test_input)

    disk_map_size = map_size(disk_map) - 1

    IO.inspect("Moving file blocks...")

    updated_disk_map =
      Enum.reduce_while(0..disk_map_size, disk_map, fn index, acc ->
        if acc[index] == "." do
          swap_blocks(acc, index)
        else
          {:cont, acc}
        end
      end)

    IO.inspect("done!")

    IO.inspect("Calculating checksum...")

    checksum =
      Enum.reduce_while(0..disk_map_size, 0, fn index, acc ->
        if updated_disk_map[index] == "." do
          {:halt, acc}
        else
          val = String.to_integer(updated_disk_map[index])

          {:cont, acc + index * val}
        end
      end)

    IO.inspect("done!")

    checksum
  end

  # TODO
  defp swap_block_chunk(disk_map, index) do
    disk_map_size = map_size(disk_map) - 1

    rear_index =
      Enum.find(disk_map_size..0, fn rear_index ->
        disk_map[rear_index] != "."
      end)

    if rear_index < index do
      {:halt, disk_map}
    else
      {:cont,
       disk_map
       |> Map.put(index, disk_map[rear_index])
       |> Map.put(rear_index, ".")}
    end
  end

  defp parse_input(input) do
    {files, free_space} =
      input
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.split_with(fn {_val, index} -> rem(index, 2) == 0 end)

    files =
      files
      |> Enum.map(&elem(&1, 0))
      |> Enum.with_index()
      |> Map.new(fn {val, index} -> {index, val} end)

    free_space =
      free_space
      |> Enum.map(&elem(&1, 0))
      |> Enum.with_index()
      |> Map.new(fn {val, index} -> {index, val} end)

    file_length = map_size(files) - 1

    disk_map =
      for x <- 0..file_length, reduce: %{} do
        acc ->
          acc_index = map_size(acc)

          file_blocks =
            1..files[x]
            |> Enum.map(fn _ -> to_string(x) end)
            |> Enum.with_index()
            |> Enum.map(fn {val, index} ->
              {acc_index + index, val}
            end)
            |> Map.new()

          free_blocks =
            String.duplicate(".", free_space[x] || 0)
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.map(fn {val, index} ->
              {acc_index + map_size(file_blocks) + index, val}
            end)
            |> Map.new()

          acc
          |> Map.merge(file_blocks)
          |> Map.merge(free_blocks)
      end

    disk_map
  end

  def print_disk(disk) do
    str =
      for x <- 0..(map_size(disk) - 1), reduce: "" do
        acc -> acc <> disk[x]
      end

    IO.inspect(str)

    :os.cmd(~c(pbcopy << EOF\n#{str}\nEOF))
  end
end
