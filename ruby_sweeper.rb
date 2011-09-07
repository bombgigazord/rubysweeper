require 'set'

module RubySweeper
  class Piece
    # TODO: FLAGS
    @MINE  = -2 #MINE, not NINE
    @BLANK = -1
    @ZERO  =  0
    @ONE   =  1
    @TWO   =  2
    @THREE =  3
    @FOUR  =  4
    @FIVE  =  5
    @SIX   =  6
    @SEVEN =  7
    @EIGHT =  8

    @num_to_numbered_piece_hash = { 0 => @ZERO,
                                    1 => @ONE,
                                    2 => @TWO,
                                    3 => @THREE,
                                    4 => @FOUR,
                                    5 => @FIVE,
                                    6 => @SIX,
                                    7 => @SEVEN,
                                    8 => @EIGHT }

    @piece_to_s_hash = { @MINE  => "*",
                         @BLANK => "#",
                         @ZERO  => "0",
                         @ONE   => "1",
                         @TWO   => "2",
                         @THREE => "3",
                         @FOUR  => "4",
                         @FIVE  => "5",
                         @SIX   => "6",
                         @SEVEN => "7",
                         @EIGHT => "8" }
    
    class << self
      attr_reader :BLANK, :MINE, :ZERO, :ONE, :TWO, :THREE, :FOUR,
                  :FIVE, :SIX, :SEVEN, :EIGHT, :num_to_numbered_piece_hash, :piece_to_s_hash

      def piece_to_s(p)
        @piece_to_s_hash[p]
      end

      def num_to_numbered_piece(num)
        piece = @num_to_numbered_piece_hash[num]
        return piece unless piece.nil?
        ## TODO: error message
      end
    end      
  end

  class Board
    attr_reader :height, :width
    @default_width = 5
    @default_height = 5

    class << self
      attr_accessor :default_width, :default_height, :played_coord_count, :game_state
      def create_board(height = Board.default_height, width = Board.default_width)
        Board.new(height, width)
      end
    end

    def initialize(height, width)
      @height = height
      @width = width
      @mine_locations = Set.new
      @surrounding_mine_numbers = Array.new(@height) { Array.new(@width) { Piece.BLANK } }
      @played_coord_count = 0
      @game_state = State.PLAYING
    end

    def set_piece(coord, piece)
      @surrounding_mine_numbers[coord.row][coord.col] = piece
    end

    def get_piece(coord)
      @surrounding_mine_numbers[coord.row][coord.col]
    end

    def add_mine(coord)
      @mine_locations << coord
    end

    def get_mine_number(coord)
      neighbor_coordinates = get_neighbors_on_board(coord)
      val = 0
      neighbor_coordinates.each do |coord|
        val += 1 if @mine_locations.include?(coord)
      end
      val
=begin
      #doesn't work if so_far is zero or if neighbor_coordinates.length.zero?
      neighbor_coordinates.inject(0) do |so_far, coord|
        so_far += 1 if @mine_locations.include?(coord)
      end
=end
    end

    #TODO: This is pretty fugly. clean it up!
    def play_coord(coord)
      return unless on_board?(coord)
      if @mine_locations.include?(coord)
        set_game_state(State.LOSS)
      end
      piece = get_piece(coord)
      return unless piece == Piece.BLANK
      set_piece(coord, Piece.num_to_numbered_piece(get_mine_number(coord)))
      @played_coord_count += 1
      if get_remaining_non_mine_coord_count.zero?
        set_game_state(State.WIN)
      end
    end

    def set_game_state(state)
      @game_state = state
    end

    def get_remaining_non_mine_coord_count
      get_total_coord_count - @mine_locations.size
    end

    def get_total_coord_count
      @height * @width
    end

    def get_played_coord_count
      @played_coord_count
    end

    #TODO: get rid of this
    def get_game_state
      @game_state
    end

    def get_neighbors_on_board(coord)
      neighbors = []
      neighbors << Coordinate.get_relative_coord(coord, -1,  -1)
      neighbors << Coordinate.get_relative_coord(coord, -1,   0)
      neighbors << Coordinate.get_relative_coord(coord, -1,   1)
      neighbors << Coordinate.get_relative_coord(coord,  0,   1)
      neighbors << Coordinate.get_relative_coord(coord,  1,   1)
      neighbors << Coordinate.get_relative_coord(coord,  1,   0)
      neighbors << Coordinate.get_relative_coord(coord,  1,  -1)
      neighbors << Coordinate.get_relative_coord(coord,  0,  -1)
      neighbors.find_all {|c| on_board?(c) }
    end

    def on_board?(coord)
      return (coord.row >= 0 and coord.col >= 0 and coord.row < height and coord.col < width)
    end

    #TODO: cleanup for usability. Should be able to take variable args *coord_lst
    def add_mines(coord_lst)
      coord_lst.each do |coord|
        add_mine(coord)
      end
    end

    #let's make this guaranteed to finish, but it might be slower for big boards
    def add_random_mines(num_mines)
      add_mines(get_random_mines(num_mines)) 
    end

    #separate fn so it can be stubbed
    def get_random_mines(num_mines)
      mine_list = []
      coord_list = get_coord_list.shuffle
      until num_mines == 0
        mine_list << coord_list.pop
        num_mines -= 1
      end
      mine_list
    end

    def get_coord_list
      coord_list = []
      (0..@height - 1).each do |y|
        (0..@width - 1).each do |x|
          coord_list << Coordinate.new(y, x)
        end
      end
      coord_list
    end

    def to_s
      str = ""
      @surrounding_mine_numbers.each_with_index do |row, row_coord|
        row.each_with_index do |col_piece, col_coord|
          coord = Coordinate.new(row_coord, col_coord)
          str << (@mine_locations.include?(coord) ? Piece.piece_to_s(Piece.MINE) : Piece.piece_to_s(get_piece(coord)))
          #str << (@mine_locations.include?(coord) ? piece_to_s(Piece.MINE) : piece_to_s(get_piece(coord)))
        end
        str << "\n"
      end
      str
    end


    # TODO: PRINT OUT THE MINE WHEN YOU DIE!
    def inspect
      str = ""
      @surrounding_mine_numbers.each_with_index do |row, row_coord|
        str << "#{height - row_coord} "
        row.each_with_index do |col_piece, col_coord|
          coord = Coordinate.new(row_coord, col_coord)
          str << Piece.piece_to_s(get_piece(coord))
        end
        str << "\n"
      end
      str << "  "
      (0..@width - 1).each do |col|
        str << UserMove.col_internal_to_user(col)
      end
      str << "\n"
    end

  end

  class Coordinate
    @INVALID_ROW = -1
    @INVALID_COL = -1
    attr_reader :row, :col

    class << self
      attr_reader :INVALID_ROW, :INVALID_COL
      def get_relative_coord(coord, row_delta, col_delta)
        Coordinate.new(coord.row + row_delta, coord.col + col_delta)
      end
    end

    def initialize(row, col)
      @row = row
      @col = col
    end

    def hash
      @row.hash ^ @col.hash
    end

    def eql?(other)
      return false unless other.instance_of?(self.class)
      @row == other.row && @col == other.col
    end

    def ==(other)
      eql?(other)
    end

    def to_s
      "row: #{@row}, col: #{@col}"
    end
  end

  class State
    @LOSS    = -1
    @PLAYING =  0
    @WIN     =  1

    class << self
      attr_reader :LOSS, :PLAYING, :WIN
    end
  end

  class Game
    def play(height, width, num_mines)
      board = Board.new(height, width)
      board.add_random_mines(num_mines)
      while board.get_game_state == State.PLAYING
        print board.inspect
        move_coord = get_move_coord_from_input(height, width)
        board.play_coord(move_coord)
      end
      puts (board.get_game_state == State.LOSS ? "YOU LOSE!" : "YOU WIN!")
    end

  end

  #NOT going to worry about validation. If the move is invalid we won't do it anyways!
  class UserMove
    class << self
      #we don't do anything iwth board width. TODO: error-checking
      def get_move_coord_from_input(board_height, board_width)
         input_list = gets.split(" ")
          row_str, col_str = input_list
          return Coordinate.new(row_str.to_i, col_str.to_i)
      end
     
      def row_user_to_internal(row_str, board_height)
        return board_height - row_str.to_i
      end

      def row_internal_to_user(row, board_height)
        return (board_height - row).to_s
      end

      #LIMIT IT TO ONE CHAR :]
      def col_user_to_internal(col_str)
        input_char = col_str[0]
        return input_char.ord - 'a'.ord
=begin
        if input_char >= 'a' and input_char <= 'z'
          return input_char.ord - 'a'.ord
        end
=end
      end

      def col_internal_to_user(col)
        a_value = 'a'.ord
        new_col_value = a_value + col
        user_col = new_col_value.chr
      end
    end
  end
end


