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
    @deck[player].show(hide_card)
  end

  def deal #deal cards to player/dealer

    @wager_amount = 0
    until @wager_amount >= @min_bet && @wager_amount <= @wallet.balance #fhec
      print "\nMoney: #{@wallet.balance} | Enter Bet $[XX] (min. $10): " #display bet request
      @wager_amount = gets.chomp.to_i  #wait for wager_amount prompt
      @wager_amount = 10 if @wager_amount == 0
      puts 'Not enough money.' if @wager_amount > @wallet.balance
    end

    @wallet.bet(@wager_amount)
    @wallet.print_balance

    @decision = ''

    print "\nPlayer Cards:"
    show_cards(0,false)

    if @deck.hands[0].blackjack == false && @deck.hands[-1].blackjack == false
      print "\nDealer Cards: "
      show_cards(1,true)

      @turn = 1
      until @decision == 's' || @deck.hands[0].value >= 21
        print "\n\n(H)it or (S)tand"
        print ' or (D)ouble down' if @turn == 1
        print '?'
        @decision = gets.chomp
        hit(0) if @decision == 'h' || @decision == '' || @decision == 'd'
        if @decision == 'd'
          print "\nAdditional "
          @wallet.bet(@wager_amount)
          @wager_amount *= 2
          @decision = 's'
        end
        @turn += 1
      end
      @decision = ''
    end

    dealer
    eval_turn(0)
    @wallet.print_balance

  end

  def hit(player)
      print "\nPlayer Cards: "
      @deck.hands[player].add_card(@deck.deal)
      @deck.hands[player].show(false)
  end

  def eval_turn(player)
    if @deck.hands[player].value > 21
      if @deck.hands[-1].value > 21
        result_push
      else
        result_lose
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

class Wallet
  attr_accessor :balance, :wager_amount

  def initialize(starting_cash)
    @balance = starting_cash.to_i
  end

  def bet(wager_amount)
    @wager_amount = wager_amount
    @balance -= @wager_amount
    print "Wager: $#{@wager_amount}"
  end

  def add(winnnings)
    @balance += winnings.to_i
  end

  def print_balance
    print " | Bankroll: $#{@balance}"
  end

end    #END OF GAME CLASS

class Hand
  attr_reader :hand, :value, :blackjack

  def initialize
    @hand = []
    @blackjack = false
  end

  def add_card(dealt_card)
    @hand << dealt_card
    value
  end

  def show(hide_card)
    @hide_card = hide_card
    @hand.each do |card|
      if @hide_card == true
        print '[hidden card] '
        @hide_card = false
      else
        print "[#{card.face} of #{card.suit}] "
      end
    end

    if hide_card == false
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
        if card.face != 'ace'
          @value += @face_value_pair[card.face]
        else
          @value += 1
          @value += 10 if (@value + 10) <= 21 && bust == false
        end
        bust = true if @value > 21
      end
    end

    if @value == 21 && @hand.length == 2
      @blackjack = true
    end

    @value
  end

end

class Hand
  attr_reader :hand, :value, :blackjack

  def initialize
    @hand = []
    @blackjack = false
  end

  def add_card(dealt_card)
    @hand << dealt_card
    value
  end

  def show(hide_card)
    @hide_card = hide_card
    @hand.each do |card|
      if @hide_card == true
        print '[hidden card] '
        @hide_card = false
      else
        print "[#{card.face} of #{card.suit}] "
      end
    end

    if hide_card == false
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
        if card.face != 'ace'
          @value += @face_value_pair[card.face]
        else
          @value += 1
          @value += 10 if (@value + 10) <= 21 && bust == false
        end
        bust = true if @value > 21
      end
    end

    if @value == 21 && @hand.length == 2
      @blackjack = true
    end

    @value
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

  def initialize()       #initialize new deck w/ deck.new
    @suits = ['clubs','diamonds','hearts','spades']
    @faces = ['ace','2','3','4','5','6','7','8','9','10','jack','queen','king']
    @deck = []

      deck do      #iterate through each array to create new deck of 52 cards
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

#-------------------------------------------------------------------------------
def create_player()   #create instances for 2 players(user & dealer)
  @player = [*0..1]   #@instanced variable (0 is user, 1 is dealer)
  @hands = []         #empty array for cards belonging to each player

  for turn in 1..2     #loop for initial deal
    for player in 0..1  #initial deal loop cycle #if at first turn of loop,
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

Game.new


#=========THE ELEPHANT GRAVEYARD LIES BEYOND===============

#SKELETONS OF OLD CODE SNIPPETS LITTER THIS PLACE.,,,ALSO HYENAS


# def shuffle # def mthd to call shuffle mid-game and pass @deck back out
#   @deck = @deck.shuffle
# end
