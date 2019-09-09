defmodule Listener do
    use GenServer

    def start_link(opts)  do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def update(server, data) do
        GenServer.call(server, {:update, data})
    end

    def get(server) do
        GenServer.call(server, {:retrieve})
    end


    # Server API
    def init(:ok) do
        {:ok, []}
    end

    def handle_call({:update, data}, _from, state) do
        {:reply, data, [data | state]}
    end

    def handle_call({:retrieve}, _from, state) do
        {:reply, state, state}
    end
end
