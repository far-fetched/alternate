defmodule Alternate.GpioService do
  defp open(gpio_number, :output) do
    case Circuits.GPIO.open("GPIO#{gpio_number}", :output) do
      {:ok, gpio} ->
        %{gpio: gpio_number, ref: gpio}

      {:error, :not_found} ->
        IO.puts("not pi platform?")
        %{gpio: gpio_number, ref: "fake:#{gpio_number}"}
    end
  end

  def read_config do
    File.read!(~c"gpio_jobs.json") |> Jason.decode()
  end

  def open_gpios(config) do
    case config do
      {:ok, json} ->
        Enum.flat_map(json["jobs"], fn job ->
          job["actions"]
        end)
        |> Enum.map(fn action -> open(action["gpio"], :output) end)
    end
  end

  def get_ref_of_gpio(data, gpio) do
    data |> Enum.find(fn action -> action[:gpio] === gpio end) |> Map.get(:ref)
  end

  def on(gpio, data) do
    IO.puts(~c"called on")
    #IO.puts(get_ref_of_gpio(data, gpio))

    Circuits.GPIO.write(get_ref_of_gpio(data, gpio), 1)
  end

  def rising_edge(gpio, data) do
    IO.puts(~c"called rising_edge")
    #IO.puts(get_ref_of_gpio(data, gpio))

    Enum.each(0..50, fn _x ->
      Circuits.GPIO.write(get_ref_of_gpio(data, gpio), 0)
      :timer.sleep(2)
      Circuits.GPIO.write(get_ref_of_gpio(data, gpio), 1)
      :timer.sleep(2)
    end)
  end

  def execute_actions(job, gpios) do
    Enum.each(job["actions"], fn action ->
      execute_action(action["name"], action["gpio"], gpios)
    end)
  end

  defp execute_action(action, gpio, data) do
    apply(__MODULE__, String.to_existing_atom(action), [gpio, data])
  end
end
