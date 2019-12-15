defmodule Day11 do
  def parse(input) do
    input |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def run(program) when is_binary(program) do
    {:halt, out} = program |> parse |> interpret([])
    out
  end

  def run(program, input) when is_binary(program) do
    {:halt, out} = program |> parse |> interpret([input])
    out
  end

  def part1(program) do
    panels = do_paint(parse(program), {{0, 0}, :up}, 0, 0, %{})
    Enum.count(panels)
  end

  def do_paint(program, {coords, _} = robot, pos, base, panels) do
    inputs = [panels[coords] || 0]

    case interpret(program, inputs, pos, [], base) do
      {:paused, [_, [colour, dir], program, pos, base]} ->
        panels = Map.put(panels, coords, colour)
        do_paint(program, move(dir, robot), pos, base, panels)

      {:halt, _} ->
        panels
    end
  end

  def move(dir, {coords, heading}) do
    new_heading = turn(dir, heading)
    new_coords = forward(coords, new_heading)
    {new_coords, new_heading}
  end

  def turn(0, :up), do: :left
  def turn(0, :left), do: :down
  def turn(0, :down), do: :right
  def turn(0, :right), do: :up

  def turn(1, :up), do: :right
  def turn(1, :right), do: :down
  def turn(1, :down), do: :left
  def turn(1, :left), do: :up

  def forward({x, y}, :up), do: {x, y + 1}
  def forward({x, y}, :right), do: {x + 1, y}
  def forward({x, y}, :down), do: {x, y - 1}
  def forward({x, y}, :left), do: {x - 1, y}

  def interpret(acc, inputs, pos \\ 0, output \\ [], base \\ 0) do
    [command_bits | rest] = Enum.drop(acc, pos)
    command_data = extract_command(command_bits)

    case command_data do
      {command, arity, modes} when command in [:add, :mul] ->
        [a, b, dest] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, base, acc)
        dest = get_output_register(base, dest, Enum.drop(modes, 2))

        result =
          case command do
            :add -> a + b
            :mul -> a * b
          end

        acc = expand_memory(acc, dest)
        new_app = List.update_at(acc, dest, fn _ -> result end)
        interpret(new_app, inputs, pos + arity + 1, output, base)

      {:input, arity, modes} ->
        case inputs do
          [] ->
            {:paused, [hd(acc), Enum.reverse(output), acc, pos, base]}

          _ ->
            [dest] = Enum.take(rest, arity)
            dest = get_output_register(base, dest, modes)
            [input | inputs] = inputs
            acc = expand_memory(acc, dest)
            new_app = List.update_at(acc, dest, fn _ -> input end)
            interpret(new_app, inputs, pos + arity + 1, output, base)
        end

      {:output, arity, modes} ->
        data = Enum.take(rest, arity)
        [result] = get_data_bits(data, modes, base, acc)
        interpret(acc, inputs, pos + arity + 1, [result | output], base)

      {:jump_if_true, arity, modes} ->
        [input, new_pos] = Enum.take(rest, arity)
        [input, new_pos] = get_data_bits([input, new_pos], modes, base, acc)

        if input == 0 do
          interpret(acc, inputs, pos + arity + 1, output, base)
        else
          interpret(acc, inputs, new_pos, output, base)
        end

      {:jump_if_false, arity, modes} ->
        [input, new_pos] = Enum.take(rest, arity)
        [input, new_pos] = get_data_bits([input, new_pos], modes, base, acc)

        if input == 0 do
          interpret(acc, inputs, new_pos, output, base)
        else
          interpret(acc, inputs, pos + arity + 1, output, base)
        end

      {:less_than, arity, modes} ->
        [a, b, dst] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, base, acc)
        dst = get_output_register(base, dst, Enum.drop(modes, 2))

        val = if a < b, do: 1, else: 0
        acc = expand_memory(acc, dst)
        acc = List.update_at(acc, dst, fn _ -> val end)
        interpret(acc, inputs, pos + arity + 1, output, base)

      {:equals, arity, modes} ->
        [a, b, dst] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, base, acc)
        dst = get_output_register(base, dst, Enum.drop(modes, 2))

        val = if a == b, do: 1, else: 0
        acc = expand_memory(acc, dst)
        acc = List.update_at(acc, dst, fn _ -> val end)
        interpret(acc, inputs, pos + arity + 1, output, base)

      {:base_adjust, arity, modes} ->
        new_base = Enum.take(rest, arity)
        [new_base] = get_data_bits(new_base, modes, base, acc)
        interpret(acc, inputs, pos + arity + 1, output, base + new_base)

      [99 | _] ->
        {:halt, [hd(acc), Enum.reverse(output), acc, pos, base]}

      seq ->
        raise "Unknown command sequence: pos: #{pos}, output: #{output}, #{inspect(seq)}"
    end
  end

  def expand_memory(app, index) when index >= length(app) do
    app ++ List.duplicate(nil, index - length(app) + 1)
  end

  def expand_memory(app, _index), do: app

  def get_data_bits(registers, modes, base, app) do
    registers
    |> Enum.with_index()
    |> Enum.map(fn {reg, index} ->
      mode = Enum.at(modes, index) || :positional

      val =
        case mode do
          :positional -> Enum.at(app, reg)
          :relative -> Enum.at(app, reg + base)
          _ -> reg
        end

      val || 0
    end)
  end

  def get_output_register(base, reg, modes) do
    case modes do
      [:relative] -> reg + base
      _ -> reg
    end
  end

  def extract_command(99) do
    [99]
  end

  def extract_command(int) do
    digits = int |> Integer.digits() |> Enum.reverse()

    cmdlist =
      case digits do
        [a, 0 | tl] -> [a | tl]
        list -> list
      end

    case map_command(cmdlist) do
      nil -> [int]
      x -> x
    end
  end

  @cmdmap %{
    1 => {:add, 3},
    2 => {:mul, 3},
    3 => {:input, 1},
    4 => {:output, 1},
    5 => {:jump_if_true, 2},
    6 => {:jump_if_false, 2},
    7 => {:less_than, 3},
    8 => {:equals, 3},
    9 => {:base_adjust, 1}
  }

  def map_command([id | tl]) when id in 1..9 do
    {cmd, arity} = @cmdmap[id]

    modes =
      Enum.map(tl, fn
        0 -> :positional
        1 -> :immediate
        2 -> :relative
      end)

    {cmd, arity, modes}
  end

  def map_command(_), do: nil
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "day5 first examples" do
    assert [3500 | _] = Day11.run("1,9,10,3,2,3,11,0,99,30,40,50", 1)
    assert [2 | _] = Day11.run("1,0,0,0,99", 1)
  end

  test "commands" do
    assert {:mul, 3, []} = Day11.extract_command(2)
    assert {:mul, 3, [:immediate]} = Day11.extract_command(102)
    assert {:mul, 3, [:positional, :immediate]} = Day11.extract_command(1002)
  end

  test "day 5 part2 examples" do
    program = """
    3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
    """

    program = program |> String.replace("\n", "") |> String.trim()

    assert [_, [999] | _] = Day11.run(program, 7)
    assert [_, [1000] | _] = Day11.run(program, 8)
    assert [_, [1001] | _] = Day11.run(program, 9)
  end

  test "day9 part 1 examples" do
    [_, output | _] = Day11.run("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")
    assert output == [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]

    [_, [num] | _] = Day11.run("1102,34915192,34915192,7,4,7,99,0")
    assert length(Integer.digits(num)) == 16

    [_, [num] | _] = Day11.run("104,1125899906842624,99")
    assert num == 1_125_899_906_842_624
  end

  test "day11 part 1" do
    IO.inspect(Day11.part1(File.read!("input.txt")), label: "part1")
  end
end
