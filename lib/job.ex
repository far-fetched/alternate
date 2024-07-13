defmodule Alternate.Job do
  use GenServer

  def start_link({gpios, job}) do
    GenServer.start_link(__MODULE__, {gpios, job})
  end

  def schedule_next(job) do
    IO.puts(~c"schedule start")
    IO.inspect(job)
    Process.send_after(self(), :toggle, job["interval_sec"])
    IO.puts(~c"schedule end")
  end

  @impl true
  def init({gpios, job}) do
    IO.puts(~c"init start")
    #data = Alternate.GpioService.read_config() |> Alternate.GpioService.open_gpios()
    schedule_next(job)
    IO.puts(~c"init end")
    IO.inspect(gpios)
    IO.inspect(job)
    {:ok, {gpios, job}}
  end

  @impl true
  def handle_info(:toggle, {gpios,job}) do
    IO.puts('toggle')
    #Alternate.GpioService.execute_action("on", 12, data)
    #Alternate.GpioService.execute_action("on", 13, data)
    #Alternate.GpioService.execute_action("rising_edge", 19, data)
    #Circuits.GPIO.write(enable, 1)
    #Circuits.GPIO.write(dir, (value && 1) || 0)

    #Enum.each(0..50, fn _x ->
      #Circuits.GPIO.write(step, 0)
      #:timer.sleep(2)
      #Circuits.GPIO.write(step, 1)
      #:timer.sleep(2)
    #end)

    schedule_next(job)
    {:noreply, {gpios, job}}
  end
end
