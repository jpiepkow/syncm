defmodule SyncM do

  def start(copy_type \\ :ram_copies)

  def start(copy_type) do
    GenServer.call(:sync_m, {:check_nodes_and_join, Node.list,copy_type})
  end
  defdelegate add_table(name, attrs), to: SyncM.Sync
end
