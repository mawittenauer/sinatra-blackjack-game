require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'maw22828158'

SUITS = %w[D S C H]
VALUES = %w[2 3 4 5 6 7 8 9 10 J Q K A]
PLAYER_INITIAL_POT = 500
BLACK_JACK = 21
DEALER_STAY_VALUE = 17

helpers do
  
  def card_image(card)
    suit = case card[0]
      when 'H' then 'hearts'
      when 'S' then 'spades'
      when 'C' then 'clubs'
      when 'D' then 'diamonds'
    end
    
    value = card[1]
    if card[1].to_i == 0
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end
    
    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end
  
  def calculate_total(cards)
    values = cards.map{ |card| card[1] }
    
    total = 0
    values.each do |value|
      if value.to_i == 'A'
        total += 11
      else
        total += value.to_i == 0 ? 10 : value.to_i
      end
    end
    
    total
  end
  
  def winner!(msg)
    session[:player_pot] += session[:player_bet]
    player_name = session[:player_name]
    player_pot = session[:player_pot]
    @play_again = true
    @success = "#{player_name} Wins! #{msg} #{player_name} now has $#{player_pot}"
  end
  
  def loser!(msg)
    session[:player_pot] -= session[:player_bet]
    player_name = session[:player_name]
    player_pot = session[:player_pot]
    @play_again = true
    @error = "#{session[:player_name]} Loses! #{msg} #{player_name} now has $#{player_pot}"
  end
  
end

before do
  @show_dealer_hit = false
  @show_hit_or_stay_buttons = true
end

 
get '/' do
  if session[:player_name]
    redirect '/game/player'
  else
    redirect '/new_game'
  end
end

get '/new_game' do
  erb :new_game
end

post '/new_game' do
  if params[:player_name].empty?
    @error = "You Must Enter a Name"
    halt erb :new_game
  end
  
  session[:player_name] = params[:player_name]
  session[:player_pot] = PLAYER_INITIAL_POT
  
  redirect '/player_bet'
end

get '/player_bet' do
  redirect '/game_over' if session[:player_pot] <= 0

  erb :player_bet
end

post '/player_bet' do
  
  player_bet = params[:player_bet].to_i
  player_pot = session[:player_pot]
  
  if player_bet == 0
    @error = "Please Enter A Valid Bet"
    halt erb :player_bet
  elsif player_bet > player_pot
    @error = "You Can't Bet More Than #{player_pot}"
    halt erb :player_bet
  end
  
  session[:deck] = SUITS.product(VALUES).shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_turn] = true
  session[:player_bet] = player_bet
  
  2.times do
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  end
  
  redirect '/game/player'
end

get '/game/player' do
  player_total = calculate_total(session[:player_cards])
  player_name = session[:player_name]
  
  if player_total == BLACK_JACK
    winner!("You Hit Blackjack!")
    @show_hit_or_stay_buttons = false
  elsif player_total > BLACK_JACK
    loser!("You Bust with a total of #{player_total}!")
    @show_hit_or_stay_buttons = false
  end
  
  erb :game
end

post '/player_hit' do
  session[:player_cards] << session[:deck].pop
  redirect '/game/player'
end

post '/player_stay' do
  session[:player_turn] = false
  
  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_hit_or_stay_buttons = false
  @show_dealer_hit = true
  dealer_total = calculate_total(session[:dealer_cards])
  
  if dealer_total == BLACK_JACK
    loser!("Dealer hit Blackjack.")
    @show_dealer_hit = false
  elsif dealer_total > BLACK_JACK
    winner!("Dealer bust with a total of #{dealer_total}")
    @show_dealer_hit = false
  elsif dealer_total >= DEALER_STAY_VALUE
    redirect '/compare'
  end
  
  erb :game
end

post '/dealer_hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/compare' do
  @show_hit_or_stay_buttons = false
  
  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])
  
  if player_total > dealer_total
    winner!("#{player_total} beats #{dealer_total}!")
  elsif player_total < dealer_total
    loser!("#{dealer_total} beats #{player_total}")
  else
    @success = "It's a tie!"
  end
  
  erb :game
end

get '/game_over' do
  erb :game_over
end
