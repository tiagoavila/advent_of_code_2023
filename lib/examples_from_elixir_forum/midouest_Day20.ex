defmodule MidouestDay19Part1 do
  def parse(input) do
    for line <- String.split(input, "\n", trim: true),
        reduce: {%{}, %{}} do
      {inputs, outputs} ->
        [input, output] = String.split(line, " -> ")
        output = String.split(output, ", ")

        {type, input} =
          case input do
            "broadcaster" -> {:broadcast, input}
            <<"%", name::binary>> -> {:flip_flop, name}
            <<"&", name::binary>> -> {:conjunction, name}
          end

        inputs =
          output
          |> Enum.reduce(inputs, fn output, inputs ->
            Map.update(inputs, output, [input], fn existing -> [input | existing] end)
          end)

        outputs = Map.put(outputs, input, {type, output})
        {inputs, outputs}
    end
  end

  def graph(inputs, outputs, state \\ %{}) do
    outputs = Map.put(outputs, "button", {:button, ["broadcaster"]})
    graph(inputs, outputs, state, ["button"], MapSet.new(), [])
  end

  def graph(_, outputs, state, [], _, edges) do
    meta =
      Enum.map(outputs, fn {sender, {type, _}} ->
        "    #{sender}[\"#{sender} (#{type})\"]"
      end)

    styles =
      Enum.flat_map(outputs, fn {name, {type, _}} ->
        case type do
          :flip_flop ->
            internal = Map.get(state, name, 0)
            fill = if internal == 1, do: "#0f0", else: "#f00"
            ["    style #{name} fill:#{fill}"]

          _ ->
            []
        end
      end)

    lines = ["graph LR"] ++ meta ++ edges ++ styles

    graph =
      lines
      |> Enum.uniq()
      |> Enum.join("\n")

    Kino.Mermaid.new(graph)
  end

  def graph(inputs, outputs, state, [sender | rest], seen, acc) do
    {_, receivers} = Map.get(outputs, sender, {nil, []})
    seen = MapSet.put(seen, sender)

    edges =
      receivers
      |> Enum.map(fn receiver ->
        "    #{sender} --> #{receiver}"
      end)

    next =
      receivers
      |> Enum.reject(fn receiver -> MapSet.member?(seen, receiver) end)

    acc = acc ++ edges
    rest = rest ++ next
    graph(inputs, outputs, state, rest, seen, acc)
  end

  def run(inputs, outputs, opts \\ []) do
    initial = Keyword.get(opts, :initial, %{})
    debug = Keyword.get(opts, :debug, false)
    render = Keyword.get(opts, :render, false)
    frame = if render, do: Kino.Frame.new() |> Kino.render(), else: nil

    run(%{
      inputs: inputs,
      outputs: outputs,
      state: initial,
      debug: debug,
      frame: frame,
      lows: 1,
      highs: 0,
      pulses: [{"button", "broadcaster", 0}]
    })
  end

  def run(%{
        inputs: inputs,
        outputs: outputs,
        state: state,
        lows: lows,
        highs: highs,
        frame: frame,
        pulses: []
      }) do
    if frame do
      term = graph(inputs, outputs, state)
      Kino.Frame.render(frame, term)
    end

    {lows, highs, state}
  end

  def run(
        %{
          inputs: inputs,
          outputs: outputs,
          state: state,
          debug: debug,
          lows: lows,
          highs: highs,
          pulses: [{sender, receiver, pulse} | rest]
        } = proc
      ) do
    {type, receivers} = Map.get(outputs, receiver, {nil, []})

    {pulse, state} =
      recv(%{
        inputs: inputs,
        sender: sender,
        receiver: receiver,
        pulse: pulse,
        type: type,
        state: state
      })

    {lows, highs, pulses} =
      case pulse do
        nil ->
          {lows, highs, []}

        0 ->
          {lows + length(receivers), highs, Enum.map(receivers, &{receiver, &1, 0})}

        1 ->
          {lows, highs + length(receivers), Enum.map(receivers, &{receiver, &1, 1})}
      end

    if debug do
      for {sender, receiver, pulse} <- pulses do
        pulse = if pulse == 0, do: "low", else: "high"
        IO.puts("#{sender} -#{pulse}-> #{receiver}")
      end
    end

    run(%{proc | state: state, pulses: rest ++ pulses, lows: lows, highs: highs})
  end

  def recv(%{type: nil, receiver: receiver, pulse: pulse, state: state}),
    do: {nil, Map.put(state, receiver, pulse)}

  def recv(%{
        type: :broadcast,
        pulse: pulse,
        state: state
      }),
      do: {pulse, state}

  def recv(%{type: :flip_flop, pulse: 1, state: state}), do: {nil, state}

  def recv(%{
        type: :flip_flop,
        receiver: receiver,
        pulse: 0,
        state: state
      }) do
    prev = Map.get(state, receiver, 0)
    next = 1 - prev
    state = Map.put(state, receiver, next)
    {next, state}
  end

  def recv(%{
        type: :conjunction,
        inputs: inputs,
        sender: sender,
        receiver: receiver,
        pulse: pulse,
        state: state
      }) do
    prev = Map.get(state, receiver, %{})
    next = Map.put(prev, sender, pulse)
    pulse = if Enum.all?(inputs[receiver], fn input -> next[input] == 1 end), do: 0, else: 1
    state = Map.put(state, receiver, next)
    {pulse, state}
  end

  def part_one(input) do
    {inputs, outputs} = parse(input)

    {lows, highs, _} =
      for _ <- 1..1000, reduce: {0, 0, %{}} do
        {lows, highs, state} ->
          {new_lows, new_highs, state} = run(inputs, outputs, initial: state)
          {lows + new_lows, highs + new_highs, state}
      end

    lows * highs
  end
end

# {inputs, outputs} = Part1.parse(input)

# {lows, highs, _} =
#   for _ <- 1..1000, reduce: {0, 0, %{}} do
#     {lows, highs, state} ->
#       {new_lows, new_highs, state} = Part1.run(inputs, outputs, initial: state)
#       {lows + new_lows, highs + new_highs, state}
#   end

# lows * highs
