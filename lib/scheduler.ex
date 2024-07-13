defmodule Alternate.Scheduler do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    IO.puts(~c"start registry")

    gpios = Alternate.GpioService.read_config() |> Alternate.GpioService.open_gpios()
    {:ok, data} = Alternate.GpioService.read_config()

    jobs =
      Enum.map(data["jobs"], fn job ->
        DynamicSupervisor.start_child(Alternate.JobSupervisor, {Alternate.Job, {gpios, job}})
      end)

    IO.inspect(jobs)
    {:ok, {gpios, jobs}}
  end

  @impl true
  def handle_cast(:start_new, {data}) do
    IO.puts(~c"start_new")

    {:noreply, {data}}
  end
end
