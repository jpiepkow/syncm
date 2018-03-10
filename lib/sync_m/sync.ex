defmodule SyncM.Sync do
  @moduledoc false
  use GenServer

  alias :mnesia, as: Mnesia

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :sync_m)
  end

  def init(state) do
    {:ok, state}
  end

  

  def handle_call({:check_nodes_and_join, [],_}, _, state) do
    with :ok <- create_schema(node()),
         :ok <- start_mnesia() 
    do
      {:reply, {:ok}, state}
    else
      _ -> {:reply, {:error}, state}
    end
  end

  def handle_call({:check_nodes_and_join, nodes, type}, _, state) do
    with :ok <- start_mnesia(),
         _ <- GenServer.multi_call([Enum.at(nodes,0)], :sync_m, {:request_join, node(),type})
    do
      {:reply, {:ok}, state}
    else
      _ -> {:reply, {:error}, state}
    end     
  end

  def handle_call({:request_join, remote_node, copy_type}, _, state) do
    with {:ok, _} <- Mnesia.change_config(:extra_db_nodes, [remote_node]),
          :ok <- Mnesia.system_info(:tables) |> copy_existing_tables(remote_node,copy_type)
    do
      {:reply, :ok, state}
    else
      _ -> {:reply, :ok, state}
    end
  end

  defp copy_existing_tables(table_list,remote_node,type) do
    Enum.map(table_list, &(Mnesia.add_table_copy(&1,remote_node,type))) 
      |> check_for_error()
  end

  defp create_schema(nodes) do
    case Mnesia.create_schema([nodes]) do
      {:error, {_, {:already_exists, _}}} -> :ok
      :ok -> :ok
      {:error, _} -> :error
    end
  end

  defp start_mnesia() do
    case Mnesia.start() do
      :ok -> :ok
      _ -> raise "Error starting Mnesia schema"
    end
  end

  def add_table(name, attrs) do
    case Mnesia.create_table(name, attributes: attrs) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, _}} -> :ok
      {:aborted, {:already_exists, _, _}} -> :ok
      _ -> :error
    end
  end

  defp check_for_error([h|t]) do
    case h do
      {:atomic, :ok} -> check_for_error(t)
      {:aborted, {:already_exists, _, _}} -> :ok
      {:aborted, {:already_exists, _}} -> check_for_error(t)
      _ -> :error
    end 
  end

  defp check_for_error([]) do
    :ok
  end
end
