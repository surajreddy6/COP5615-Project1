[n, k] = System.argv
{n, _} = Integer.parse(n)
{k, _} = Integer.parse(k)

work_unit = 5
node_list = [
    :"foo@suraj",
    :"bar@suraj"
]

num_nodes = length(node_list)

node_names = Enum.map(0..num_nodes-1, fn (i) ->
   "Node" <> Integer.to_string(i) |> String.to_atom
end)

#IO.puts "Len : #{num_nodes}"

start_points = :lists.seq(1, n, n/num_nodes |> :math.ceil |> Kernel.trunc)

{:ok, listener} = Listener.start_link([])

compute_end_points = fn (s, num_nodes, n) ->
    k = (n / num_nodes |> :math.ceil |> Kernel.trunc)
    if s + k > n do
        n
    else
        s + k
    end
end

end_points = Enum.map(start_points, &(compute_end_points.(&1, num_nodes, n)))

pids = Enum.map(0..num_nodes-1, fn (i) ->
    node_name = Enum.fetch!(node_names, i)
    Node.spawn_link Enum.fetch!(node_list, i), fn -> Child.start_link([], name: node_name) end
end)

IO.inspect pids

Enum.map(0..num_nodes-1, fn (i) ->
    # pid = Enum.fetch!(pids, i)
    start_point = Enum.fetch!(start_points, i)
    end_point = Enum.fetch!(end_points, i)
    node_name = Enum.fetch!(node_names, i)
    node = Enum.fetch!(node_list, i)
    Child.compute({node_name, node}, [start_point, end_point, k, work_unit])
end)


Enum.map(0..num_nodes-1, fn (i) ->
    pid = Enum.fetch!(pids, i)
    {:ok, state_after_exec} = :sys.get_state(pid)
end)

result = Listener.get(listener)
result = List.flatten(result)
sorted_result = Enum.sort(result)
Enum.map(sorted_result, &IO.puts(&1))



