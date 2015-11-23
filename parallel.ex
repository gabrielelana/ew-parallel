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
    |> Enum.map(&task(&1, f))
    |> collect(Keyword.get(opts, :timeout, 5_000))
  end

  defp task(e, f) do
    me = self
    reference = make_ref
    pid = spawn(fn -> send(me, {reference, f.(e)}) end)
    Process.monitor(pid)
    {reference, pid}
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

      {task, result} ->
        case List.keytake(tasks, task, 0) do
          {_, tasks} ->
            collect(tasks, [result|results], reference)
          nil ->
            collect(tasks, results, reference)
        end

      {:"DOWN", _, _, pid, _} ->
        case List.keytake(tasks, pid, 1) do
          {_, tasks} ->
            collect(tasks, [:error|results], reference)
          nil ->
            collect(tasks, results, reference)
        end
    end
  end
end

:random.seed(:os.timestamp)

0..10
|> Enum.map(fn _ -> :random.uniform(1_000) - 500 end)
|> Parallel.map(&Waste.ms/1, timeout: 2_000)
|> IO.inspect
