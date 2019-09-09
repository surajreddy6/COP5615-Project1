defmodule Parent do
  use GenServer

  def start_link(opts)  do
      GenServer.start_link(__MODULE__, :ok, opts)
  end

  def compute(server, args) do
  GenServer.cast(server, {:compute, args})
  end

  def init(:ok) do
      {:ok, []}
  end

  def handle_cast({:compute, args}, state) do
    [start_point, end_point, k, n, listener] = args
    size = end_point - start_point + 1
    total_process_limit = 80000
    num_servers = 8
    server_process_limit = total_process_limit / num_servers |> :math.ceil |> Kernel.trunc
    work_unit =
      if size > 150 do
        ((size / num_servers |> :math.ceil |> Kernel.trunc) / server_process_limit) |>:math.ceil |> Kernel.trunc
      else
        5
      end

    # calculating start and end points for each child node based on size
    start_points = :lists.seq(start_point, end_point, size/num_servers |> :math.ceil |> Kernel.trunc)
    compute_end_points = fn (s, num_servers, size) ->
        k = (size / num_servers |> :math.ceil |> Kernel.trunc) - 1
        if s + k > n do
            n
        else
            s + k
        end
    end
    end_points = Enum.map(start_points, &(compute_end_points.(&1, num_servers, size)))

    # start num_servers GenServers
    pids = Enum.map(0..length(start_points)-1, fn (i) ->
      Child.start_link([])
    end)

    # send start and end values to each child node
    Enum.map(0..length(start_points) - 1, fn (i) ->
        start_point = Enum.fetch!(start_points, i)
        end_point = Enum.fetch!(end_points, i)
        {:ok, server_pid} = Enum.fetch!(pids, i)
        Child.compute(server_pid, [start_point, end_point, k, work_unit, listener])
    end)

    # wait for async node to complete computation
    Enum.map(0..length(start_points)-1, fn (i) ->
        {:ok, pid} = Enum.fetch!(pids, i)
        state_after_exec = :sys.get_state(pid, :infinity)
    end)

    {:noreply, state}
  end
end
