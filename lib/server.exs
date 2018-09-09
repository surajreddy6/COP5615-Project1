[n, k] = System.argv
{n, _} = Integer.parse(n)
{k, _} = Integer.parse(k)

work_unit = 5
node_list = [
    :"foo@Aditis-MacBook-Pro",
    :"bar@Aditis-MacBook-Pro"
]

num_nodes = length(node_list)

node_names = Enum.map(0..num_nodes-1, fn (i) ->
   "NodeB" <> Integer.to_string(i) |> String.to_atom
end)

#IO.puts "Len : #{num_nodes}"
IO.puts "Start points"
start_points = :lists.seq(1, n, n/num_nodes |> :math.ceil |> Kernel.trunc)
IO.inspect start_points

{:ok, listener} = Listener.start_link([])

compute_end_points = fn (s, num_nodes, n) ->
    k = (n / num_nodes |> :math.ceil |> Kernel.trunc) - 1
    if s + k > n do
        n
    else
        s + k
    end
end

IO.puts "End points"
end_points = Enum.map(start_points, &(compute_end_points.(&1, num_nodes, n)))
IO.inspect end_points

pids = Enum.map(0..num_nodes-1, fn (i) ->
    node_name = Enum.fetch!(node_names, i)

    IO.inspect :rpc.call(Enum.fetch!(node_list, i), Child, :start_link, [[name: node_name]])
end)

IO.inspect pids

Enum.map(0..num_nodes-1, fn (i) ->
    # pid = Enum.fetch!(pids, i)
    start_point = Enum.fetch!(start_points, i)
    end_point = Enum.fetch!(end_points, i)
    node_name = Enum.fetch!(node_names, i)
    node = Enum.fetch!(node_list, i)
    Child.compute({node_name, node}, [start_point, end_point, k, work_unit, listener])
end)


# :timer.sleep(5000)
Enum.map(0..num_nodes-1, fn (i) ->
    {:ok, pid} = Enum.fetch!(pids, i)
    state_after_exec = :sys.get_state(pid)
end)


result = Listener.get(listener)
IO.inspect result

result = List.flatten(result)
sorted_result = Enum.sort(result)
# Enum.map(sorted_result, &IO.puts(&1))

IO.inspect sorted_result
