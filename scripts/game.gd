extends Control

var board: Array = []

# Can be Player Turn or AI Turn
var Turn: String = "Player Turn"
# Can be Move or Block
var Turn_Type: String = "Move"



func print_board():
	for row in board:
		print(row)

func _ready() -> void:
	
	# INITIATE BOARD ARRAY
	#
	# 0 - Empty Squares
	# 1 - Player 1
	# 2 - Player AI
	# -1 - Blocked Squares
	#
	for row in range(8):
		var new_row = []  # Make an empty new row before filling it.
		for col in range(8):
			new_row.append(0) # 0 for empty squares.
		board.append(new_row)  # Add the row to the board
	board[7][3] = 1
	board[0][4] = 2
	
	# Determine first turn
	var first_turn : int = randi() % 2
	if first_turn == 1:
		Turn = "Player Turn"
	elif first_turn == 0:
		Turn = "AI Turn"
	
	#var b = get_node("7-3")
	print_board()
	test_check_around_position()
	#b.set_button_icon()
	
# Maybe make this into an update game func
func determine_turn():
	
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
	

func ai_play():
	pass
	
func calculate_position(boardPosX: int, boardPosY: int, old_board: Array = board):
	# Make a new board for in depth calculations
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

#region Test Functions

func test_check_around_position():
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
