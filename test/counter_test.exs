defmodule CounterTest do
    use ExUnit.Case, async: True

    setup do
        {:ok, agent} = Counter.start_link([])
        %{agent: agent}
    end

    test "stores values and retrieve list", %{agent: agent} do
        assert Counter.get(agent) == []

        Counter.put(agent, 1)
        Counter.put(agent, 2)
        assert Counter.get(agent) == [2, 1]
    end
end