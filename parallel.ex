defmodule Fibonacci do
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: of(n - 1) + of(n - 2)
end

defmodule Waste do
  def ms(n) do
    :timer.sleep(n)
    n
  end
end

defmodule Parallel do
  def map(enumerable, f, opts \\ []) do
    enumerable
    |> Enum.map(&Task.async(fn -> f.(&1) end))
    |> collect(Keyword.get(opts, :timeout, 5_000))
  end

  defp collect(tasks, timeout) do
    reference = make_ref
    timer = Process.send_after(self, {:timeout, reference}, timeout)

    try do
      collect(tasks, [], reference)
    after
      :erlang.cancel_timer(timer)
      receive do
        {:timeout, ^reference} ->
          :ok
      after 0 ->
        :ok
      end
    end
  end

  defp collect([], results, _), do: {:ok, results |> Enum.reverse}
  defp collect(tasks, results, reference) do
    receive do
      {:timeout, ^reference} ->
        {:timeout, length(results), results |> Enum.reverse}

      message ->
        case Task.find(tasks, message) do
          {result, task} ->
            collect(List.delete(tasks, task), [result|results], reference)
          nil ->
            collect(tasks, results, reference)
        end
    end
  end
end

:random.seed(:os.timestamp)

0..10
|> Enum.map(fn _ -> :random.uniform(2_000) + 1_000 end)
|> Parallel.map(&Waste.ms/1, timeout: 2_000)
|> IO.inspect
