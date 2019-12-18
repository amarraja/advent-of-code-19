defmodule Day14 do
  def run(reactions) do
    reactions = parse_reactions(reactions)
    {_, ores} = react([{"FUEL", 1}], reactions, %{}, 0)
    ores
  end

  def react([{"ORE", needed} | rest], reactions, store, ores) do
    react(rest, reactions, store, ores + needed)
  end

  def react([], _reactions, store, ores) do
    {store, ores}
  end

  def react([{chemical, needed} | rest], reactions, store, ores) do
    {from_store, store} =
      store
      |> Map.get_and_update(chemical, fn
        nil ->
          {0, 0}

        qty_stored ->
          used = min(qty_stored, needed)
          remaining = qty_stored - used
          {used, remaining}
      end)

    still_needed = needed - from_store
    {count, ingredients} = reactions[chemical]
    reactions_needed = ceil(still_needed / count)

    ingredients =
      Enum.map(ingredients, fn {name, one_reaction} -> {name, one_reaction * reactions_needed} end)

    {store, ores} = react(ingredients, reactions, store, ores)

    made = reactions_needed * count
    waste = made - still_needed

    store = Map.update(store, chemical, waste, fn current_waste -> current_waste + waste end)
    react(rest, reactions, store, ores)
  end

  def parse_reactions(reactions) do
    reactions
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "=>"))
    |> Enum.map(fn line ->
      [ingredients, [{chemical, amount}]] = Enum.map(line, &line_to_tuples/1)
      {chemical, {amount, ingredients}}
    end)
    |> Enum.into(%{})
  end

  def line_to_tuples(line) do
    line
    |> String.split(",")
    |> Enum.map(fn segment ->
      {num, name} = segment |> String.trim() |> Integer.parse()
      {String.trim(name), num}
    end)
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "examples" do
    input = """
    10 ORE => 10 A
    1 ORE => 1 B
    7 A, 1 B => 1 C
    7 A, 1 C => 1 D
    7 A, 1 D => 1 E
    7 A, 1 E => 1 FUEL
    """

    assert Day14.run(input) == 31

    input = """
    9 ORE => 2 A
    8 ORE => 3 B
    7 ORE => 5 C
    3 A, 4 B => 1 AB
    5 B, 7 C => 1 BC
    4 C, 1 A => 1 CA
    2 AB, 3 BC, 4 CA => 1 FUEL
    """

    assert Day14.run(input) == 165

    input = """
    157 ORE => 5 NZVS
    165 ORE => 6 DCFZ
    44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
    12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
    179 ORE => 7 PSHF
    177 ORE => 5 HKGWZ
    7 DCFZ, 7 PSHF => 2 XJWVT
    165 ORE => 2 GPVTF
    3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
    """

    assert Day14.run(input) == 13312
  end

  test "part1" do
    Day14.run(File.read!("input.txt")) |> IO.inspect(label: "part1")
  end
end
