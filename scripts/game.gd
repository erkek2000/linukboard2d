extends Control

# The Board
var Board: Array = []

# Can be Player Turn or AI Turn
var Turn: String = "Player Turn"
# Can be Move or Block
var Turn_Type: String = "Move"
# Gives Player Position, updated once every turn.
var Player_Pos: Vector2 = Vector2(7, 3)
# Gives AI Position, updated once every turn.
var AI_Pos: Vector2 = Vector2(0, 4)
# Gives Player Move Position, updated twice every turn.
var Signal_Pos: Vector2 = Vector2(-1, -1)


# Called when node enters the scene. (on load)
func _ready() -> void:
	
	initiate_board()
	determine_first_turn()
	run_game()
	
	#test_calculate_position()
	#print_board()
	
	#var b = get_node("7-3")
	#b.set_button_icon()


func initiate_board() -> void:
	# INITIATE BOARD ARRAY
	#
	# 0 - Empty Squares
	# 1 - Player 
	# 2 - Player AI
	# -1 - Blocked Squares
	#
	for row in range(8):
		var new_row = []  # Make an empty new row before filling it.
		for col in range(8):
			new_row.append(0) # 0 for empty squares.
		Board.append(new_row)  # Add the row to the Board
	Board[7][3] = 1 # Player
	Board[0][4] = 2 # AI


func determine_first_turn() -> void:
	var first_turn : int = randi() % 2
	if first_turn == 1:
		Turn = "Player Turn"
	elif first_turn == 0:
		Turn = "AI Turn"


func run_game() -> void:
	# check Get Move
	# check_victory()
	# change_turn()
	# check Get Block
	# check_victory()
	# change_turn()
	 # DISABLE BUTTONS
	# AI PLAY
	# check Get Move
	# check_victory()
	# change_turn()
	# check Get Block
	# check_victory()
	# change_turn()
	pass


func ai_play():
	pass
	
# Maybe make this into an update game func
func change_turn() -> void:
	if Turn == "Player Turn":
		if Turn_Type == "Move":	
			Turn_Type = "Block"
		else:
			Turn = "AI Turn"
	else:
		if Turn_Type == "Move":
			Turn_Type = "Block"
		else:
			Turn = "Player Turn"
	


func print_board() -> void:
	for row in Board:
		print(row)


func check_victory() -> int:
	if calculate_position(Player_Pos.x, Player_Pos.y) <= 0:
		return 2 # AI Victory
	elif calculate_position(AI_Pos.x, AI_Pos.y) <= 0:
		return 1 # Player Victory
	else:
		return 0 # Playable


func calculate_position(boardPosX: int, boardPosY: int, old_board: Array = Board) -> int:
	# Make a new Board for in depth calculations
	var new_board: Array = old_board
	var point: int = 0
	if new_board[boardPosX][boardPosY] != 0:
		# if not a valid position return 0
		return point
		
	# OLD CODE, CHECK IF WORKS
	# Check positions around the given coordinates
	for i in range(boardPosX - 1, boardPosX + 2):
		for j in range(boardPosY - 1, boardPosY + 2):
			if index_in_bounds(i, 8) and index_in_bounds(j, 8):
				if new_board[i][j] == 0:
					point += 1
		# No need for try/except in GDScript for index checking
		# If index is out of bounds, it will simply not enter the if statement

	# Point-1 because it counts the position we are checking too.
	return point - 1

# Helper function to check if an index is within bounds
func index_in_bounds(index: int, size: int) -> bool:
	return index >= 0 and index < size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#region SIGNALS
# Button Pressed signal form BoardMaker.
# Probably won't need y,x parameters.
func _on_board_maker_send_location(name, y, x) -> void:
	print(name)
	pass # Replace with function body.
#endregion

#region TEST_FUNCTIONS


func test_calculate_position() -> void:
	var oldBoard = [
		[0, 1, 0, 0],
		[0, 0, 1, 0],
		[1, 0, 0, 0],
		[0, 0, 0, 1]
	]

	var result = calculate_position(1, 1, oldBoard)
	print("Test Case 1 - Expected: 5, Got: ", result)  # (1,1) has two adjacent zeroes

	result = calculate_position(0, 0, oldBoard)
	print("Test Case 2 - Expected: 2, Got: ", result)  # (0,0) has one adjacent zero

	result = calculate_position(2, 2, oldBoard)
	print("Test Case 3 - Expected: 6, Got: ", result)  # (2,2) has three adjacent zeroes

	result = calculate_position(3, 3, oldBoard)
	print("Test Case 4 - Expected: -1, Got: ", result) # (3,3) only counts itself and no adjacent zeroes

	result = calculate_position(-1, -1, oldBoard)
	print("Test Case 5 - Expected: -1, Got: ", result) # Out of bounds case
#endregion
