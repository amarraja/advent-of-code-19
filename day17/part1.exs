defmodule Day17 do
  Code.require_file("../day15/intcode.exs")

  def run(program) do
    {:halt, [_, map | _]} =
      program
      |> Intcode.parse()
      |> Intcode.interpret()

    IO.puts("---------")
    IO.puts(map)
    IO.puts("\n\n---------")

    map
    |> to_charlist()
    |> to_string()
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      for {chr, x} <- Enum.with_index(String.codepoints(line)), into: [] do
        {{x, y}, chr}
      end
    end)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&get_intersecting/1)
    |> List.flatten()
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def get_intersecting([a, b, c]) do
    get_intersecting(a, b, c, [])
  end

  def get_intersecting(
        [{{_, _}, "."}, {{_, _}, "#"}, {{_, _}, "."} | _] = a,
        [{{_, _}, "#"}, {intloc, "#"}, {{_, _}, "#"} | _] = b,
        [{{_, _}, "."}, {{_, _}, "#"}, {{_, _}, "."} | _] = c,
        acc
      ) do
    get_intersecting(tl(a), tl(b), tl(c), [intloc | acc])
  end

  def get_intersecting([_ | tla], [_ | tlb], [_ | tlc], acc) do
    get_intersecting(tla, tlb, tlc, acc)
  end

  def get_intersecting(_, _, _, acc) do
    acc
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "part1" do
    Day17.run(File.read!("input.txt")) |> IO.inspect(label: "part1")
  end
end
