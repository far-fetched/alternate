defmodule Alternate.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    # children = [
    # Alternate
    # ]

    # Supervisor.init(children, strategy: :one_for_one)
    children = [
      {DynamicSupervisor, name: Alternate.JobSupervisor, strategy: :one_for_one},
      Alternate.Scheduler
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
