#Begin list of defined clssses for various in-game assets and gameplay operations executed
class Deck                 #Begin defining class for deck of 52 cards
  attr_reader :deck, :hands

  def initialize()       #initialize new deck w/ deck.new
    @suits = ['clubs','diamonds','hearts','spades']
    @faces = ['ace','2','3','4','5','6','7','8','9','10','jack','queen','king']
    @deck = []

      deck do      #iterate through each array to create new deck of 52 cards
        @suits.each do |suit|  #iterate 4 times, once per suit
          @faces.each do |face| #iterate 14 times for each card.
             @deck << Card.new(suit, face) #one loop = (1suit x14faces) x all 4 suits
      end
        @deck    #pass out instanced @deck variable
      end

      def shuffle #define method to easily call shuffle mid-game and pass @deck back out
        @deck = @deck.shuffle
      end
    end

    def deal       #method for draw one card from deck and pass @dealt_card instance var
      @dealt_card = @deck.shift #remove next card frok sarray and pass it to @dealt_card
      if @deck.length == 0   #if current shuffled deck empty. re-initialize new deck
        initialize()
        @deck.shuffle
      end
      @dealt_card         #pass out @dealt_card var
    end
  end
end
#-------------------------------------------------------------------------------
def create_player()   #create instances for 2 players(user & dealer)
  @player = [*0..1]   #@instanced variable (0 is user, 1 is dealer)
  @hands = []         #empty array for cards belonging to each player

  for turn in 1..2     #loop for initial deal
    for player in 0..1                        #initial deal loop cycle
      @hands[player] = Hand.new if turn == 1 #if at first turn of loop, initialize new hand
      @hands[player].add_card(deal)       # add new card to player's hand
      @hands[player].value                # recalculate new hand total
    end
  end
end
#-------------------------------------------------------------------------------
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
end
