defmodule WorkerTest do
    use ExUnit.Case, async: True

    setup do
        {:ok, agent} = Counter.start_link([])
        %{agent: agent}
    end

    test "test worker", %{agent: agent} do
        # Initialize test params
        k = 24
        start_point = 1
        work_unit = 40

        Worker.run([k, start_point, work_unit, agent])
        assert Counter.get(agent) == [25, 20, 9, 1]
    end
end