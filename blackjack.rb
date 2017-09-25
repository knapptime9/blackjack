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

      def shuffle
        @deck = @deck.shuffle
      end
    end

    def deal
      @dealt_card = @deck.shift
      if @deck.length == 0
        initialize(5)
        @deck.shuffle
      end
      @dealt_card
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
