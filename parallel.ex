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
    |> Enum.map(&Task.async(fn -> f.(&1) end))
    |> Enum.map(&Task.await/1)
  end
end

:random.seed(:os.timestamp)

0..10
|> Enum.map(fn _ -> :random.uniform(1_000) end)
|> Parallel.map(&Waste.ms/1)
|> IO.inspect

