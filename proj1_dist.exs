# taking in commandline args
[n, k] = System.argv
{n, _} = Integer.parse(n)
{k, _} = Integer.parse(k)

# list of remote child nodes
node_list = [
    :"star@Aditis-MacBook-Pro.local",
    :"bar@Aditis-MacBook-Pro.local"
]
num_nodes = length(node_list)
node_names = Enum.map(0..num_nodes-1, fn (i) ->
   "NodeH" <> Integer.to_string(i) |> String.to_atom
end)

# work_unit for each node
work_unit =
  if n > 100 do
    100
  else
    5
  end

# start GenServer on the node "Listener"
# to recieve final computed values from the remote nodes
{:ok, listener} = Listener.start_link([])

#calculating start and end points for each child node based on input "n"
start_points = :lists.seq(1, n, n/num_nodes |> :math.ceil |> Kernel.trunc)
compute_end_points = fn (s, num_nodes, n) ->
    k = (n / num_nodes |> :math.ceil |> Kernel.trunc) - 1
    if s + k > n do
        n
    else
        s + k
    end
end
end_points = Enum.map(start_points, &(compute_end_points.(&1, num_nodes, n)))

# start GenServer on child nodes
pids = Enum.map(0..num_nodes-1, fn (i) ->
    node_name = Enum.fetch!(node_names, i)
    :rpc.call(Enum.fetch!(node_list, i), Child, :start_link, [[name: node_name]])
end)

# send start and end values to each child node
Enum.map(0..num_nodes-1, fn (i) ->
    start_point = Enum.fetch!(start_points, i)
    end_point = Enum.fetch!(end_points, i)
    node_name = Enum.fetch!(node_names, i)
    node = Enum.fetch!(node_list, i)
    Child.compute({node_name, node}, [start_point, end_point, k, work_unit, listener])
end)

# wait for async node to complete computation
Enum.map(0..num_nodes-1, fn (i) ->
    {:ok, pid} = Enum.fetch!(pids, i)
    state_after_exec = :sys.get_state(pid, :infinity)
end)

# getting final result from "Listener"
result = Listener.get(listener)
result = List.flatten(result)
sorted_result = Enum.sort(result)
Enum.map(sorted_result, &IO.puts(&1))
