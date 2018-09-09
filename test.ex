compute_end_points = fn (s, num_nodes, n) ->
    k = (n / num_nodes |> :math.ceil |> Kernel.trunc) - 1
    if s + k > n do
        n
    else
        s + k
    end
end