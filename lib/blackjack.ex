defmodule Blackjack do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def get_score(face) do
    case face do
      "A" -> 1
      "J" -> 10
      "Q" -> 10
      "K" -> 10
      _ -> face
    end
  end

  def create_deck do
    for suit <- ["Spades", "Hearts", "Clubs", "diamonds"],
        face <- ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"] do
      %{suit: suit, value: face, score: get_score(face)}
    end
  end

  def shuffle do
    create_deck() |> Enum.shuffle()
  end

  def hit(hand, deck) do
    {card, deck} = List.pop_at(deck, 0)
    {hand ++ List.wrap(card), deck}
  end

  def initial_deal do
    deck = shuffle()
    {first_card, remaining_cards} = hit([], deck)
    second_deal = hit(first_card, remaining_cards)
    second_deal
  end

  def hand_score(hand) do

    #hand = [%{score: 10, suit: "Hearts", value: "K"},%{score: 10, suit: "Hearts", value: "Q"}]
    Enum.reduce(hand, 0, fn(x, acc) -> x.score + acc end)

  end

end
