defmodule Child do
    use GenServer

    def start_link(opts)  do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def compute(server, args) do
        GenServer.cast(server, {:compute, args})
    end

    # Server API
    def init(:ok) do
        {:ok, []}
    end

    def handle_cast({:compute, args}, state) do
        [start_point, end_point, k, work_unit, listener] = args
        {:ok, counter} = Counter.start_link([])
        start_points = :lists.seq(start_point, end_point, work_unit)
        end_points =
          Enum.map start_points, fn i ->
            if i + work_unit - 1 > end_point do
              end_point
            else
              i + work_unit - 1
            end
          end
        pids = Enum.map(0..length(start_points) - 1, fn(i) ->
          Worker.start_link([])
        end)
        Enum.map(0..length(start_points) - 1, fn(i) ->
          {:ok, pid} = Enum.fetch!(pids, i)
          Worker.compute(pid, [k, Enum.fetch!(start_points, i), Enum.fetch!(end_points, i), counter])
        end)

        Enum.map(0..length(start_points) - 1, fn (i) ->
            {:ok, pid} = Enum.fetch!(pids, i)
            state_after_exec = :sys.get_state(pid, :infinity)
        end)
        # # tasks = Enum.map(start_points, &Task.async(Worker, :run, [[k, &1, work_unit, counter]]))
        # Enum.map(tasks, &Task.await(&1, :infinity)) # Large timeout
        state = Counter.get(counter)
        Listener.update(listener, state)
        {:noreply, state}
    end
end
