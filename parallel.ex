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
  def map(enumerable, f) do
    enumerable
    |> Enum.zip(1..Enum.count(enumerable))
    |> Enum.map(&Task.async(fn -> {f.(elem(&1, 0)), elem(&1, 1)} end))
    |> collect
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
  end

  defp collect(tasks, results \\ [])

  defp collect([], results), do: results |> Enum.reverse
  defp collect(tasks, results) do
    receive do
      message ->
        case Task.find(tasks, message) do
          {result, task} ->
            collect(List.delete(tasks, task), [result|results])
          nil ->
            collect(tasks, results)
        end
    end
  end
end

:random.seed(:os.timestamp)

0..10
|> Enum.map(fn _ -> :random.uniform(1_000) end)
|> IO.inspect
|> Parallel.map(&Waste.ms/1)
|> IO.inspect
