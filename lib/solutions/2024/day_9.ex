defmodule Solutions.Year2024Day9 do
  @behaviour Solution

  @test_input "2333133121414131402"

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  1928
  """
  def solve_part_1(input) do
    {disk_map, _} = parse_input(input)

    disk_map_size = map_size(disk_map) - 1

    updated_disk_map =
      Enum.reduce_while(0..disk_map_size, disk_map, fn index, acc ->
        if acc[index] == "." do
          swap_blocks(acc, index)
        else
          {:cont, acc}
        end
      end)

    checksum =
      Enum.reduce_while(0..disk_map_size, 0, fn index, acc ->
        if updated_disk_map[index] == "." do
          {:halt, acc}
        else
          val = String.to_integer(updated_disk_map[index])

          {:cont, acc + index * val}
        end
      end)

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
  def solve_part_2(input) do
    {disk_map, block_indexes} = parse_input(input)

    {updated_disk_map, _} =
      block_indexes.files
      |> Enum.reverse()
      |> Enum.reduce({disk_map, block_indexes.free_space}, fn {f_index, file_id, f_count}, acc ->
        {disk_map, free_space_indexes} = acc

        {{fs_index, fs_count}, fsi_index} =
          free_space_indexes
          |> Enum.with_index()
          |> Enum.find({{nil, nil}, nil}, fn {{_, fs_count}, _index} -> fs_count >= f_count end)

        if is_nil(fs_index) or fs_index > f_index do
          acc
        else
          new_free_space_indexes =
            if fs_count == f_count do
              List.delete_at(free_space_indexes, fsi_index)
            else
              new_space_info = {fs_index + f_count, fs_count - f_count}

              List.replace_at(free_space_indexes, fsi_index, new_space_info)
            end

          file_updates =
            fs_index..(fs_index + f_count - 1)
            |> Enum.map(fn index -> {index, to_string(file_id)} end)
            |> Map.new()

          free_space_updates =
            f_index..(f_index + f_count - 1)
            |> Enum.map(fn index -> {index, "."} end)
            |> Map.new()

          new_disk_map = disk_map |> Map.merge(file_updates) |> Map.merge(free_space_updates)

          {new_disk_map, new_free_space_indexes}
        end
      end)

    disk_map_size = map_size(updated_disk_map) - 1

    checksum =
      Enum.reduce(0..disk_map_size, 0, fn index, acc ->
        if updated_disk_map[index] == "." do
          acc
        else
          val = String.to_integer(updated_disk_map[index])

          acc + index * val
        end
      end)

    checksum
  end

  defp parse_input(input) do
    {raw_files, raw_free_space} =
      input
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.split_with(fn {_val, index} -> rem(index, 2) == 0 end)

    files =
      raw_files
      |> Enum.map(&elem(&1, 0))
      |> Enum.with_index()
      |> Map.new(fn {val, index} -> {index, val} end)

    free_space =
      raw_free_space
      |> Enum.map(&elem(&1, 0))
      |> Enum.with_index()
      |> Map.new(fn {val, index} -> {index, val} end)

    file_length = map_size(files) - 1

    {blocks, block_indexes} =
      for x <- 0..file_length, reduce: {%{}, %{files: [], free_space: []}} do
        {blocks, block_indexes} ->
          current_size = map_size(blocks)

          file_blocks =
            1..files[x]
            |> Enum.map(fn _ -> to_string(x) end)
            |> Enum.with_index()
            |> Enum.map(fn {val, index} ->
              {current_size + index, val}
            end)
            |> Map.new()

          free_block_index = current_size + map_size(file_blocks)

          free_blocks =
            String.duplicate(".", free_space[x] || 0)
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.map(fn {val, index} ->
              {free_block_index + index, val}
            end)
            |> Map.new()

          file_indexes =
            if files[x] == 0 do
              block_indexes.files
            else
              [{current_size, x, files[x]} | block_indexes.files]
            end

          free_space_indexes =
            if is_nil(free_space[x]) || free_space[x] == 0 do
              block_indexes.free_space
            else
              [{free_block_index, free_space[x]} | block_indexes.free_space]
            end

          blocks =
            blocks
            |> Map.merge(file_blocks)
            |> Map.merge(free_blocks)

          block_indexes =
            block_indexes
            |> Map.put(:files, file_indexes)
            |> Map.put(:free_space, free_space_indexes)

          {blocks, block_indexes}
      end

    block_indexes =
      block_indexes
      |> Map.update!(:files, &Enum.reverse/1)
      |> Map.update!(:free_space, &Enum.reverse/1)

    {blocks, block_indexes}
  end

  def print_disk(disk) do
    str =
      for x <- 0..(map_size(disk) - 1), reduce: "" do
        acc ->
          str =
            if String.length(disk[x]) > 1 do
              "(#{disk[x]})"
            else
              disk[x]
            end

          acc <> str
      end

    IO.inspect(str)

    # :os.cmd(~c(pbcopy << EOF\n#{str}\nEOF))
  end
end
