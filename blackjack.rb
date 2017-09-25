class Game
  def initialize       #.initialize special method allows for new instance with ,new
    print 'Welcome Back, So are we gonna play some Blackjack or what? (Y/N) '
    user_command = gets.chomp.downcase   #await keyboard input THEN pass input w/ endline marks removed

    if user_command == 'y' || user_command == '' #conditional for starting new game = yes
      @deck = Deck.new()        #initialize new deck
      @deck.shuffle     #shuffle deck
      @wallet = Wallet.new(100)       #initialize starting bankroll
      @min_bet = 10

      play_again = ''

      #game over conditional below-keeps iterating until either user enters n or wallet drops below 10 dollars necessary for min bet
      until play_again == 'n' || @wallet.balance < @min_bet
        deal
        if @wallet.balance >= @min_bet  #PLAYER has not run out of money, so playt again?
          print ' | Play another hand? (Y/N)'
          play_again = gets.chomp           #wait for keyboard input
        end
      end
      puts "\nNot enough money!" if @wallet.balance < @min_bet #actions for wallet below 10
      puts "\nGame over!"
    else
      puts "\nMaybe next time. Bye!"       #actions if n entered for play again
    end
  end


  def show_cards(player,hide_card) #method instructing app to reveal hidden cards
    @deck.hands[player].show(hide_card)
  end

  def deal #triggers the initial deal of 2 cards to player and dealer
    @deck.create_player(1) #would allow for multiple players vs dealer, force set to 0

    @wager_amount = 0   #conditional check waiting for input that must be greater than  min bet and less than or equal to balance
    until @wager_amount >= @min_bet && @wager_amount <= @wallet.balance #fhec
      print "\nMoney: #{@wallet.balance} | Enter Bet $[XX] (min. $10): " #display bet request
      @wager_amount = gets.chomp.to_i  #wait for wager_amount prompt
      @wager_amount = 10 if @wager_amount == 0 #default action if player leaves prompt empty and hits enter (bets min 10)
      puts 'Not enough money.' if @wager_amount > @wallet.balance
    end

    @wallet.bet(@wager_amount) #calls .bet method in Wallet Class
    @wallet.print_balance

    @decision = '' #define instance var for command input prompt to be  passed to gets.chomp each time in game loop

    print "\nPlayer Cards:" #text displayed before displaying dealt cards
    show_cards(0,false) #show cards of Player 0, hide_card = false so displayed and card val added to total

#line below checks initial hands of all players EXCEPT the dealer to see if any players were dealt blackjack.  @deck.hands[-1] refers to next to last index of array which will be the last PLAYER, the DEALER always occupies final index
    if @deck.hands[0].blackjack == false && @deck.hands[-1].blackjack == false
      print "\nDealer Cards: " #nobody has blackjack so deal cards
      show_cards(1,true)

      @turn = 1 #gameplay hit stand loop.  turn 1 unique because it triggers initialize new hand array for that player and turn 1 is only time player allowed to double down
      until @decision == 's' || @deck.hands[0].value >= 21
        print "\n\n(H)it or (S)tand"
        print ' or (D)ouble down' if @turn == 1 #if it first turn, displays option to double down
        print '?'
        @decision = gets.chomp #waits for new command input
        #durihg turn 1, 3 out of 4 commands all trigger a "hit" and one card is drawn from the deck and passed to players hAnd
        hit(0) if @decision == 'h' || @decision == '' || @decision == 'd'
        if @decision == 'd'
          print "\nAdditional "
          @wallet.bet(@wager_amount)
          @wager_amount *= 2
          @decision = 's'
        end
        @turn += 1 #increase turn counter by 1, reset @decision var to accept new input, repeat loop.
      end
      @decision = ''
    end
#after decision s invoked or bust state triggered, escape loop, then run actions for dealers hand
    dealer
    eval_turn(0)
    @wallet.print_balance

  end

  def hit(player) #deal 1 card, face up and push to players hand
      print "\nPlayer Cards: "
      @deck.hands[player].add_card(@deck.deal) #invoke deal new card action
      @deck.hands[player].show(false)   #ensure all cards show face up
  end

  def eval_turn(player) #evaluate new hand score and assess conditionals (trigger bust state and lose or auto stand at 21
    if @deck.hands[player].value > 21
      if @deck.hands[-1].value > 21
        result_push #push new score back to game loop
      else
        result_lose #TRIGGER LOSE STATE ACTIONS
      end
    elsif @deck.hands[player].blackjack == true
      if @deck.hands[-1].blackjack == true
        result_push
      else
        result_win
      end
    elsif @deck.hands[player].value == @deck.hands[-1].value
      if @deck.hands[-1].blackjack == true
        result_lose
      else
        result_push
      end
    elsif @deck.hands[player].value < @deck.hands[-1].value
      if @deck.hands[-1].value > 21
        result_win
      else
        result_lose
      end
    else
      result_win
    end
  end

  def dealer
    print "\nDealer Cards: "
      until @deck.hands[-1].value  >= 17
        @deck.hands[-1].add_card(@deck.deal)
      end
      @deck.hands[-1].show(false)
  end

  def result_push
    @wallet.add(@wallet.wager_amount)
    print "\n\nPush!"
  end

  def result_win
    winnings = @wager_amount * 2
    winnings += @wager_amount * 0.5 if @deck.hands[0].blackjack == true
    @wallet.add(winnings)
    profit = winnings - @wager_amount
    print "\n\nPlayer wins $#{profit}!"
  end

  def result_lose
    print "\n\nYou lose #{@wager_amount}!"
  end

class Wallet #lass containing instanced current balance and methods for initializing, updating, disolaying current balance
  attr_accessor :balance, :wager_amount

  def initialize(starting_cash)
    @balance = starting_cash.to_i
  end

  def bet(wager_amount)
    @wager_amount = wager_amount
    @balance -= @wager_amount
    print "Wager: $#{@wager_amount}"
  end

  def add(winnings) #adds winnings to new balance
    @balance += winnings.to_i
  end

  def print_balance  #prints updated balance
    print " | Bankroll: $#{@balance}"
  end

end    #END OF GAME CLASS

class Hand
  attr_reader :hand, :value, :blackjack

  def initialize  #whats generated upon invoking Hand.new.  This resets the players cards and hand values on each game
    @hand = []
    @blackjack = false
  end

  def add_card(dealt_card) # adds the @dealt_card to player's @hand and recalcs value
    @hand << dealt_card
    value
  end

  def show(hide_card)  #method for handling whether card "state" is face down/up and what to do in each circumstance
    @hide_card = hide_card
    @hand.each do |card|
      if @hide_card == true
        print '[hidden card] '
        @hide_card = false
      else
        print "[#{card.face} of #{card.suit}] "
      end
    end

    if hide_card == false   #both cards are face up, if still in play, print new hand val. if @blackjack or bust conditions met triggering bust or BJ state, ...=true, print those corresponding messagfes
      print "| Value: #{@value} "
      print "- BLACKJACK!" if @blackjack == true
      print '- BUST!' if @value > 21
    end

  end

  def value
    @face_value_pair = {'ace'=>[1,11],'2'=>2,'3'=>3,'4'=>4,'5'=>5,'6'=>6,'7'=>7,
      '8'=>8,'9'=>9,'10'=>10,'jack'=>10,'queen'=>10,'king'=>10}

    bust = false
    2.times do
      @value = 0
      @hand.each do |card|
        if card.face != 'ace' #conditional for evalutating if ace is 1 or 11
          @value += @face_value_pair[card.face]
        else
          @value += 1
          @value += 10 if (@value + 10) <= 21 && bust == false
        end
        bust = true if @value > 21 #conditions required to trigger 'bust' state
      end
    end

    if @value == 21 && @hand.length == 2 #conditions required to trigger blackjack state
      @blackjack = true
    end

    @value #NEW UPDATED VALUE INSTANCE PASSED BACK T9 LOOP
  end

end



#Begin list of defined clssses for various
#in-game assets and gameplay operations
class Card
  attr_reader :suit, :face

  def initialize(suit,face)
    @suit = suit
    @face = face
  end
end

class Deck                 #Begin defining class for deck of 52 cards
  attr_reader :deck, :hands

  def initialize       #initialize new deck w/ deck.new
    @suits = ['clubs','diamonds','hearts','spades']
    @faces = ['ace','2','3','4','5','6','7','8','9','10','jack','queen','king']
    @deck = []

       1.times do    #iterate through each array to create new deck of 52 cards
        @suits.each do |suit|  #iterate 4 times, once per suit
          @faces.each do |face| #iterate 14 times for each card.
            @deck << Card.new(suit, face) #1 loop=(1suit x14faces)*all 4 suits
            end
          end
        end

    @deck    #pass out instanced @deck variable
  end

    def deal    #methd take one cardand pass @dealt_card instance var
      @dealt_card = @deck.shift #rmv card frok sarray,pass to @dealt_card
      if @deck.length == 0   #if current deck empty. re-initialize new deck
        initialize()
        @deck.shuffle
      end
      @dealt_card         #pass out @dealt_card var
    end

    def create_player(num_players)   #create instances for 2 players(user & dealer)
      @player = [*0..num_players]   #@instanced variable (0 is user, 1 is dealer)
      @hands = []         #empty array for cards belonging to each player

      for turn in 1..2     #loop for initial deal
        for player in 0..num_players  #initial deal loop cycle #if at first turn of loop,
          @hands[player] = Hand.new if turn == 1  #initialize new hand
          @hands[player].add_card(deal)       # add new card to player's hand
          @hands[player].value                # recalculate new hand total
        end
      end

    end

  def shuffle
    @deck = deck.shuffle
  end
end
end

#-------------------------------------------------------------------------------

Game.new      #end of Code, this starts game by initializing new instance of Class game
