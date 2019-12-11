defmodule Day07 do
  def parse(input) do
    input |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def find_highest_signal(program) do
    program = parse(program)

    range = 0..4

    combos =
      for a <- range,
          b <- range,
          c <- range,
          d <- range,
          e <- range,
          length(Enum.uniq([a, b, c, d, e])) == 5,
          do: [a, b, c, d, e]

    combos
    |> Enum.map(&get_thruster_signal(program, &1))
    |> Enum.max()
  end

  def get_thruster_signal(program, phase_settings) do
    Enum.reduce(phase_settings, 0, fn phase_setting, last_output ->
      {_, [out | _]} = interpret(program, [phase_setting, last_output])
      out
    end)
  end

  def interpret(acc, inputs) do
    interpret(acc, 0, [], inputs)
  end

  def interpret(acc, pos, output, inputs) do
    [command_bits | rest] = Enum.drop(acc, pos)
    command_data = extract_command(command_bits)

    case command_data do
      {command, arity, modes} when command in [:add, :mul] ->
        [a, b, dest] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, acc)

        result =
          case command do
            :add -> a + b
            :mul -> a * b
          end

        new_app = List.update_at(acc, dest, fn _ -> result end)
        interpret(new_app, pos + arity + 1, output, inputs)

      {:input, arity, _modes} ->
        [dest] = Enum.take(rest, arity)
        [input | inputs] = inputs
        new_app = List.update_at(acc, dest, fn _ -> input end)
        interpret(new_app, pos + arity + 1, output, inputs)

      {:output, arity, modes} ->
        data = Enum.take(rest, arity)
        [result] = get_data_bits(data, modes, acc)
        interpret(acc, pos + arity + 1, [result | output], inputs)

      {:jump_if_true, arity, modes} ->
        [input, new_pos] = Enum.take(rest, arity)
        [input, new_pos] = get_data_bits([input, new_pos], modes, acc)

        if input == 0 do
          interpret(acc, pos + arity + 1, output, inputs)
        else
          interpret(acc, new_pos, output, inputs)
        end

      {:jump_if_false, arity, modes} ->
        [input, new_pos] = Enum.take(rest, arity)
        [input, new_pos] = get_data_bits([input, new_pos], modes, acc)

        if input == 0 do
          interpret(acc, new_pos, output, inputs)
        else
          interpret(acc, pos + arity + 1, output, inputs)
        end

      {:less_than, arity, modes} ->
        [a, b, dst] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, acc)

        val = if a < b, do: 1, else: 0
        acc = List.update_at(acc, dst, fn _ -> val end)
        interpret(acc, pos + arity + 1, output, inputs)

      {:equals, arity, modes} ->
        [a, b, dst] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, acc)

        val = if a == b, do: 1, else: 0
        acc = List.update_at(acc, dst, fn _ -> val end)
        interpret(acc, pos + arity + 1, output, inputs)

      [99 | _] ->
        {hd(acc), output}

      seq ->
        raise "Unknown command sequence: pos: #{pos}, output: #{output}, #{inspect(seq)}"
    end
  end

  def get_data_bits(registers, modes, app) do
    registers
    |> Enum.with_index()
    |> Enum.map(fn {reg, index} ->
      mode = Enum.at(modes, index) || :positional
      if mode == :positional, do: Enum.at(app, reg), else: reg
    end)
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
    8 => {:equals, 3}
  }

  def map_command([id | tl]) when id in 1..8 do
    {cmd, arity} = @cmdmap[id]

    modes =
      Enum.map(tl, fn
        0 -> :positional
        1 -> :immediate
      end)

    {cmd, arity, modes}
  end

  def map_command(_), do: nil
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "first examples" do
    program = Day07.parse("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0")
    assert Day07.get_thruster_signal(program, [4, 3, 2, 1, 0]) == 43210

    program =
      Day07.parse("3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0")

    assert Day07.get_thruster_signal(program, [0, 1, 2, 3, 4]) == 54321

    program =
      Day07.parse(
        "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
      )

    assert Day07.get_thruster_signal(program, [1, 0, 4, 3, 2]) == 65210
  end

  test "part1" do
    IO.inspect(Day07.find_highest_signal(File.read!("input1.txt")), label: "part1")
  end
end
