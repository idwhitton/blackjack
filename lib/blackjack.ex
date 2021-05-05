defmodule Blackjack do
  use GenServer

  # -------------#
  # Client - API #
  # -------------#

  def start_link() do
    GenServer.start_link(__MODULE__, {})
  end

  def start_game(pid) do
    GenServer.call(pid, :start_game)
  end

  def view_hand(pid) do
    GenServer.call(pid, :view_hand)
  end

  def view_score(pid) do
    GenServer.call(pid, :view_score)
  end

  def hit_me(pid) do
    GenServer.call(pid, :hit_me)
  end

  def stick(pid) do
    GenServer.call(pid, :stick)
  end

  def new_round(pid) do
    GenServer.call(pid, :new_round)
  end

  ##---------- ##
  #Server - API #
  ##-----------##

  def init(list) do
    {:ok, list}
  end

  def handle_call(:start_game, _from, _hand) do
    current_hand = []
    deck = shuffle()
    {first_card, remaining_cards} = hit(current_hand, deck)
    second_deal = hit(first_card, remaining_cards)
    {:reply, elem(second_deal, 0), second_deal}
  end

  def handle_call(:new_round, _from, list) do
    add_to_end = elem(list, 1) ++ List.wrap(elem(list, 0))
    {first_card, remaining_cards} = hit([], add_to_end)
    second_deal = hit(first_card, remaining_cards)
    {:reply, elem(second_deal, 0), second_deal}
  end

  def handle_call(:hit_me, _from, list) do

    hand = elem(list, 0)
    deck = elem(list, 1)
    new_combination = hit(hand, deck)
    hand_score = hand_score(elem(new_combination, 0))

    new_hand = elem(new_combination, 0)

    cond  do
      length(new_hand) == 5 -> {:reply, {:ok, "You won!! 5 card trick!, another round?"}, new_combination}
      hand_score < 21 -> {:reply, new_hand, new_combination}
      hand_score == 21 -> {:reply, {:ok, "You won!! You got 21!, another round?"}, new_combination}
    true -> {:reply, {:error, "Sorry you bust! Score is #{hand_score}, play again?"}, new_combination}
    end

  end

  def handle_call(:stick, _from, list) do

    hand = elem(list, 0)
    hand_score = hand_score(hand)

    {:reply, "You finished on #{hand_score}, play again?", list}

  end

  def handle_call(:view_hand, _from, list) do
    {:reply, elem(list, 0), list}
  end

  def handle_call(:view_score, _from, list) do
    {:reply, hand_score(elem(list, 0)), list}
  end

  defp hit(hand, deck) do
    {card, deck} = List.pop_at(deck, 0)
    {hand ++ List.wrap(card), deck}
  end

  defp create_deck do
    for suit <- ["Spades", "Hearts", "Clubs", "diamonds"],
        face <- ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"] do
      %{value: face, suit: suit}
    end
  end

  defp shuffle do
    create_deck() |> Enum.shuffle()
  end

  defp hand_score(hand) do
    max_score = Enum.reduce(hand, 0, fn(x, acc) -> get_face_value(x.value) + acc end)
    number_of_aces = count_A(hand)
    cond do
      max_score > 21 && number_of_aces > 0 -> do_for_A(max_score, number_of_aces)
      true -> max_score
    end

  end

  defp count_A(my_hand) do
    Enum.count(my_hand, & &1.value == "A")
  end

  defp do_for_A(max_score, ace_count) do
    score_1 = max_score - (10 * (ace_count - 1))
    score_2 = max_score - (10 * ace_count)
    if score_1 <= 21 do
      score_1
    else
      score_2
    end
  end

  defp get_face_value(face) do
    case face do
      "A" -> 11
      "J" -> 10
      "Q" -> 10
      "K" -> 10
      _ -> face
    end
  end

end
