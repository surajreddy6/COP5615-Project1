defmodule Counter do
    use Agent

    @doc """
    Starts a new agent and initialize with an empty list
    """
    def start_link(_opts) do
        Agent.start_link(fn -> [] end)
    end

    @doc """
    Puts a value in the list
    """
    def put(agent, value) do
        Agent.update(agent, &([value | &1]))
    end

    @doc """
    Gets the list
    """
    def get(agent) do
        Agent.get(agent, &(&1))
    end
end