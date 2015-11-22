defmodule Fibonacci do
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: of(n - 1) + of(n - 2)
end

defmodule Parallel do
  def map(enumerable, f) do
    me = self
    enumerable
    |> Enum.map(fn(e) ->
                  spawn_link(fn -> send me, {self, f.(e)} end)
                end)
    |> Enum.map(fn(pid) ->
                  receive do {^pid, result} -> result end
                end)
  end
end

0..35
# |> Enum.map(&Fibonacci.of/1)
|> Parallel.map(&Fibonacci.of/1)
|> IO.inspect

