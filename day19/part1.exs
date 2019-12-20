defmodule Day19 do
  Code.require_file("../day15/intcode.exs")

  def run(program) do
    program = Intcode.parse(program)

    affected_coordinates =
      for x <- 0..49, y <- 0..49, into: [] do
        {:halt, [_, [x] | _]} = Intcode.interpret(program, [x, y])
        x
      end

    Enum.sum(affected_coordinates)
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "foo" do
    Day19.run(File.read!("input.txt")) |> IO.inspect()
  end
end
