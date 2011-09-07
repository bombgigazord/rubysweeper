require './ruby_sweeper'
include RubySweeper

describe Piece do
end

describe Board do
  it 'should have the right constructor default values' do
    board = Board.create_board
    board.height.should == 5
    board.width.should == 5
  end

  it 'should have the right values set by constructor' do
    board = Board.create_board(10,20)
    board.height.should == 10
    board.width.should == 20
  end

  it 'should set and get the right piece' do
    board = Board.create_board(5, 4)
    coord = Coordinate.new(2, 3)
    board.set_piece(coord, Piece.ONE)
    board.get_piece(coord).should == Piece.ONE
  end

  it 'should get the right to_s value for a blank board' do
    board = Board.create_board(2, 3)
    board.to_s.should == "###\n###\n"
  end

  it 'should add the right amount of random mines' do
    board = Board.new(3, 3) 
    coord1 = Coordinate.new(0, 0)
    coord2 = Coordinate.new(0, 1)
    coord3 = Coordinate.new(1, 0)
    board.stub!(:get_random_mines).and_return([coord1, coord2, coord3])
    board.add_random_mines(3)
    board.to_s.should == "**#\n*##\n###\n"
  end

  it 'should get the right list of shuffled mines' do
    board = Board.new(3, 3) 
    coord_list = board.get_coord_list
    board.stub!(:shuffle).and_return(coord_list)
    board.get_random_mines(3).length.should == 3
  end

  it 'should return the right coord_list' do
    board = Board.new(3, 3)
    board.get_coord_list.length.should == 9
  end

  it 'should get the right to_s value for a board with pieces set' do
    board = Board.create_board(2, 3)
    coord1 = Coordinate.new(0, 1)
    coord2 = Coordinate.new(1, 2)
    board.set_piece(coord1, Piece.EIGHT)
    board.set_piece(coord2, Piece.TWO)
    board.to_s.should == "#8#\n##2\n"
  end

  it 'should get the right to_s value with a mine on the board' do
    board = Board.create_board(2, 3)
    coord = Coordinate.new(0, 1)
    board.add_mine(coord)
    board.to_s.should == "#*#\n###\n"
  end

  it 'should generate the right mine number for a given spot with no mines' do
    board = Board.create_board(2, 3)
    coord = Coordinate.new(0, 1)
    board.get_mine_number(coord).should == 0
  end

  it 'should be on the board' do
    board = Board.create_board(2, 3)
    coord = Coordinate.new(0, 1)
    board.on_board?(coord).should be true
  end

  it 'should be off the board to the top' do
    board = Board.create_board(2, 3)
    coord = Coordinate.new(-1, 1)
    board.on_board?(coord).should be false
  end

  it 'should be off the board to the left' do
    board = Board.create_board(2, 3)
    coord = Coordinate.new(1, -1)
    board.on_board?(coord).should be false
  end

  it 'should be off the board to the right' do
    board = Board.create_board(2, 3)
    coord = Coordinate.new(1, 3)
    board.on_board?(coord).should be false
  end

  it 'should be off the board to the bottom' do
    board = Board.create_board(2, 3)
    coord = Coordinate.new(2, 2)
    board.on_board?(coord).should be false
  end

  it 'should only include neighbors on the board' do
    board = Board.create_board(2, 2)
    coord = Coordinate.new(0, 0)
    right_coord = Coordinate.new(0, 1)
    bottom_right_coord = Coordinate.new(1, 1)
    bottom_coord = Coordinate.new(1, 0)
    neighbors = board.get_neighbors_on_board(coord)
    neighbors.length.should == 3
    neighbors.include?(right_coord).should == true
    neighbors.include?(bottom_right_coord).should == true
    neighbors.include?(bottom_coord).should == true
  end

  it 'should get the right mine number' do
    board = Board.create_board(2, 2)
    coord = Coordinate.new(0, 0)
    mine_coord1 = Coordinate.new(0, 1)
    mine_coord2 = Coordinate.new(1, 1)
    mine_coord3 = Coordinate.new(1, 0)
    board.add_mine(mine_coord1)
    board.add_mine(mine_coord2)
    board.add_mine(mine_coord3)
    board.get_mine_number(coord).should == 3 
  end

  it 'should update the right piece upon selecting it' do
    board = Board.create_board(2, 2)
    coord = Coordinate.new(0, 0)
    mine_coord = Coordinate.new(0, 1)
    board.add_mine(mine_coord)
    board.play_coord(coord)
    board.get_played_coord_count.should == 1
    board.to_s.should == "1*\n##\n"
  end

  it 'should not update the piece if it has already been updated' do
    board = Board.create_board(2, 2)
    coord = Coordinate.new(0, 0)
    mine_coord = Coordinate.new(0, 1)
    board.add_mine(mine_coord)
    board.play_coord(coord)
    board.play_coord(coord)
    board.get_played_coord_count.should == 1
    board.to_s.should == "1*\n##\n"
  end

  it 'should return a LOSS state if a mine is selected' do
    board = Board.create_board(2, 2)
    mine_coord = Coordinate.new(0, 1)
    board.add_mine(mine_coord)
    board.play_coord(mine_coord)
    board.get_game_state.should == State.LOSS
  end

  it 'should return a WIN state if the right number of pieces becomes uncovered' do
    board = Board.create_board(2, 2)
    coord = Coordinate.new(0, 0)
    mine_coord1 = Coordinate.new(0, 1)
    mine_coord2 = Coordinate.new(1, 1)
    mine_coord3 = Coordinate.new(1, 0)
    board.add_mine(mine_coord1)
    board.add_mine(mine_coord2)
    board.add_mine(mine_coord3)
    board.get_game_state == State.WIN
  end

  it 'should return a PLAYING state if the game is still going on' do
    board = Board.create_board(2, 2)
    coord = Coordinate.new(0, 0)
    mine_coord1 = Coordinate.new(0, 1)
    mine_coord2 = Coordinate.new(1, 1)
    #mine_coord3 = Coordinate.new(1, 0)
    board.add_mine(mine_coord1)
    board.add_mine(mine_coord2)
    #board.add_mine(mine_coord3)
    board.get_game_state == State.PLAYING
  end

  it 'should not affect a board if the played piece is off-board' do
    board = Board.create_board(2, 2)
    coord = Coordinate.new(3, 3)
    board.to_s.should == "##\n##\n"
    board.play_coord(coord)
    board.to_s.should == "##\n##\n"
  end
end

describe Coordinate do
  before(:each) do
    @c1 = Coordinate.new(2, 3)
    @c2 = Coordinate.new(2, 3)
  end

  it 'should be constructed properly' do
    @c1.row.should == 2
    @c1.col.should == 3
  end

  it 'should have same eql? if the row and col are the same' do
    @c1.eql?(@c2).should be true
  end

  it 'should hash to the same bucket if row and col are the same' do
    @c1.hash.should == @c2.hash
  end

  it 'should return a new correct coordinate without changing the original' do
    coord = Coordinate.new(2, 3)
    modified_coord = Coordinate.get_relative_coord(coord, 1, 1)
    modified_coord.should_not == coord
    modified_coord.row.should == 3
    modified_coord.col.should == 4
  end

end

describe Game do
end

describe UserMove do
  before(:all) do
    @board = Board.new(5, 5)
  end

  it 'should correctly convert to a user row' do
    internal_row = 4
    user_row = UserMove.row_internal_to_user(internal_row, @board.height)
    user_row.should == "1"
  end

  it 'should correctly convert from a user row' do
    user_row = "1"
    internal_row = UserMove.row_user_to_internal(user_row, @board.height)
    internal_row.should == 4
  end

  it 'should correctly convert to a user col' do 
    input_col = 3
    user_col = UserMove.col_internal_to_user(input_col)
    user_col.should == "d"
  end

  it 'should correctly convert from a user col' do 
    user_col = "b"
    internal_col = UserMove.col_user_to_internal(user_col)
    internal_col.should == 1
  end

  it 'should correctly convert to a user  move' do 
    
  end

  it 'should correctly convert from a user  move' do 
  end

  it 'should generate an invalid coord if row is bad' do
  end

  it 'should generate an invalid coord if col is bad' do
  end
end
