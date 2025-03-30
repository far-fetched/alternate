defmodule Alternate.GpioService do
  defp open(gpio_number, mode) do
    case Circuits.GPIO.open("GPIO#{gpio_number}", mode) do
      {:ok, gpio} ->
        %{gpio: gpio_number, ref: gpio}

      {:error, :not_found} ->
        IO.puts("not pi platform?")
        IO.puts(gpio_number)
        IO.puts(mode)
        %{gpio: gpio_number, ref: "fake:#{gpio_number}"}
    end
  end

  def read_config do
    File.read!(~c"gpio_jobs.json") |> Jason.decode()
  end

  def open_gpios(config) do
    case config do
      {:ok, json} ->
        # Enum.concat(
        Enum.flat_map(json["jobs"], fn job ->
          job["actions"]
        end)
        |> Enum.map(fn a ->
          case Map.has_key?(a, "gpio") do
            true ->
              case a["name"] do
                "on" -> %{gpio: a["gpio"], mode: :output}
                "off" -> %{gpio: a["gpio"], mode: :output}
                "wait_for" -> %{gpio: a["gpio"], mode: :input}
              end

            false ->
              nil
          end
        end)
        # Enum.flat_map(json["jobs"], fn job ->
        # job["actions"]
        # end)
        # |> Enum.map(fn a ->
        # case Map.has_key?(a, "wait_for") do
        # true -> %{gpio: a["wait_for"]["gpio"], mode: :input}
        # false -> nil
        # end
        # end)
        # Enum.map(json["jobs"], fn job ->
        # case Map.has_key?(job["scheduler"], "wait_for") do
        # true -> %{gpio: job["scheduler"]["wait_for"]["gpio"], mode: :input}
        # false -> nil
        # end
        # end)
        # Enum.flat_map(json["jobs"], fn job ->
        # case Map.has_key?(job["scheduler"], "wait_for") do
        # true -> %{gpio: job["scheduler"]["wait_for"]["gpio"], mode: :input}
        # false -> nil
        # end
        # end)
        # )
        |> Enum.filter(&(!is_nil(&1)))
        |> Enum.uniq_by(fn x -> x.gpio end)
        |> Enum.map(fn gpio ->
          open(gpio.gpio, gpio.mode)
        end)

        # |> Enum.map(fn s ->
        # case Map.has_key?(s, :wait_for) do
        # true -> %{gpio: s["wait_for"]["gpio"], mode: :input}
        # false -> nil
        # end
        # end)

        # |> Enum.map(fn action -> open(action["gpio"], :output) end), Enum.flat_map(json["jobs"], fn job ->
        # job["scheduler"] end) |> Enum.map(fn sh ->
        # open(sh["wait_for"]["gpio"], :output)))

        # {:ok, json} ->
        # Enum.concat(Enum.flat_map(json["jobs"], fn job ->
        # job["actions"]
        # end)
        # |> Enum.map(fn action -> open(action["gpio"], :output) end), Enum.flat_map(json["jobs"], fn job ->
        # job["scheduler"] end) |> Enum.map(fn sh ->
        # open(sh["wait_for"]["gpio"], :output)))
    end
  end

  def get_ref_of_gpio(data, gpio) do
    data
    |> Enum.find(fn action -> action[:gpio] === gpio end)
    |> Map.get(:ref)
  end

  def on(gpio, data, opts) do
    IO.puts(~c"called on")
    my_write(get_ref_of_gpio(data, gpio), 1)
  end

  def off(gpio, data, opts) do
    IO.puts(~c"called off")
    my_write(get_ref_of_gpio(data, gpio), 0)
  end

  def rising_edge(gpio, data, opts) do
    IO.puts(~c"called rising_edge")
    # IO.puts(get_ref_of_gpio(data, gpio))

    Enum.each(0..opts["step"], fn _x ->
      my_write(get_ref_of_gpio(data, gpio), 0)
      :timer.sleep(1)
      my_write(get_ref_of_gpio(data, gpio), 1)
      :timer.sleep(1)
    end)
  end

  def delay(gpio, data, opts) do
    IO.puts(~c"call delay")
    :timer.sleep(opts["sec"])
  end

  def wait_for(gpio, data, opts) do
    expected_value = opts["expected_value"]

    case my_read(get_ref_of_gpio(data, gpio)) do
      value when value === expected_value ->
        IO.puts(~c"found process next")
      _ ->
        IO.puts(~c"not found")
        :timer.sleep(500)
        wait_for(gpio, data, opts)
    end
  end

  def execute_actions(job, gpios) do
    case can_execute(job) do
      {:ok} ->
        Enum.each(job["actions"], fn action ->
          execute_action(action["name"], action["gpio"], gpios, action["opts"])
        end)

      {:wait} ->
        IO.puts(~c"wait schedule")

        case check_wait(job, gpios) do
          {:ok} ->
            Enum.each(job["actions"], fn action ->
              execute_action(action["name"], action["gpio"], gpios, action["opts"])
            end)

          _ ->
            IO.puts(~c"still wait")
        end
    end
  end

  def check_wait(job, gpios) do
    expected = job["scheduler"]["wait_for"]["expected_value"]
    IO.puts(~c"find")
    IO.inspect(expected)

    case my_read(get_ref_of_gpio(gpios, job["scheduler"]["wait_for"]["gpio"])) do
      read when read === expected ->
        {:ok}

      _ ->
        {:wait}
    end
  end

  defp can_execute(job) do
    case job["scheduler"]["type"] do
      "interval" ->
        {:ok}

      "delay" ->
        {:wait}
    end
  end

  defp execute_action(action, gpio, data, opts) do
    apply(__MODULE__, String.to_existing_atom(action), [gpio, data, opts])
  end

  defp my_read(ref) when is_binary(ref) do
    IO.puts(~c"call fake read")
    1
  end

  defp my_write(ref, value) when is_binary(ref) do
    IO.puts(~c"call fake write with value")
    IO.inspect(value)
    IO.puts(~c"and gpio")
    IO.inspect(ref)
  end

  defp my_write(ref, value) do
    Circuits.GPIO.write(ref, value)
  end
end
