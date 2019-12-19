defmodule Day15 do
  Code.require_file("intcode.exs")

  def run(program) do
    program
    |> Intcode.prepare()
    |> walk(1..4)
  end

  def walk(prog, dirs, steps \\ 1) do
    Enum.reduce(dirs, 0, fn dir, acc ->
      {_status, prog} = Intcode.step([dir], prog)

      case get_first_output(prog) do
        0 -> nil
        1 -> walk(prog, next_dir(dir), steps + 1)
        2 -> IO.puts("Min path at: #{steps}")
      end
    end)
  end

  def get_first_output([_hd, [o | _] | _]), do: o

  def next_dir(dir) do
    case dir do
      1 -> [1, 3, 4]
      2 -> [2, 3, 4]
      3 -> [1, 2, 3]
      4 -> [1, 2, 4]
    end
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "part1" do
    Day15.run(File.read!("input.txt")) |> IO.inspect(label: "part1")
  end
end
