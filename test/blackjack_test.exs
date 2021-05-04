defmodule BlackjackTest do
  use ExUnit.Case
  doctest Blackjack

  setup do
    {:ok,server_pid} = Blackjack.start_link()
    {:ok,server: server_pid}
  end
end
