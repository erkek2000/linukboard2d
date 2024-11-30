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
# Variable that changes every time board is clicked.
var New_Button_Signal: bool = false
# BoardMaker Node - for accessing buttons
var Board_Maker : Node

# Called when node enters the scene. (on load)
func _ready() -> void:
	
	# Wait until buttons are ready.
	while Board_Maker == null:
		continue
		
	initiate_board()
	determine_first_turn()
	get_move()
	#move_icon(Board_Maker.get_node('7-3'), Board_Maker.get_node('7-7'), Vector2(7,7))
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
	print ("First Turn is ", Turn)


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


func get_move():
	toggle_buttons(Board_Maker, true)
	# Wait until a button is clicked.
	# THIS LOOP MUST GO.
	while New_Button_Signal != true:
		continue
	
	var new_pos: Vector2 = Signal_Pos
	# This should be in a loop
	if check_move(Player_Pos, new_pos):
		# Move player on Board
		move_player(new_pos)
		# Stringify the vectors so they can reach buttons.
		var player_pos_string = vector2_to_string(Player_Pos)
		var new_pos_string = vector2_to_string(new_pos)
		# Move button icons
		move_icon(Board_Maker.get_node(player_pos_string), Board_Maker.get_node(new_pos_string), new_pos)


func vector2_to_string(vec: Vector2) -> String:
	return str(vec.x) + "-" + str(vec.y)


func move_icon(old_pos :Node, new_pos: Node, on_board_new_pos: Vector2):
	# Handle Button icons for positions
	var old_pos_icon = old_pos.get_button_icon()
	var new_pos_icon = new_pos.get_button_icon()
	old_pos.set_button_icon(new_pos_icon)
	new_pos.set_button_icon(old_pos_icon)


func move_player(new_pos: Vector2):
	# Move on Board
	Board[Player_Pos.x][Player_Pos.y] = 0
	Board[new_pos.x][new_pos.y] = 1
	Player_Pos = new_pos


func place_block(pos: Node, on_board_pos: Vector2):
	# Should be similar to move_player.
	# Set Icon
	Board[on_board_pos.x][on_board_pos.y] = -1
	pass


func check_move(old_pos: Vector2, new_pos: Vector2) -> bool:
	var delta_x = abs(new_pos.x - old_pos.x)
	var delta_y = abs(new_pos.y - old_pos.y)
	# return if the move is withing 1 square of the old position.
	return delta_x <= 1 and delta_y <= 1

func ai_play():
	pass


# Function to toggle the interactivity of buttons
func toggle_buttons(parent: Node, is_turn: bool):
	for child in parent.get_children():
		if child is Button:
			child.disabled = not is_turn


# Maybe make this into an update game func
func change_turn() -> void:
	if Turn == "Player Turn":
		toggle_buttons(Board_Maker, true)
		if Turn_Type == "Move":
			Turn_Type = "Block"
		else:
			Turn = "AI Turn"
	else:
		toggle_buttons(Board_Maker, false)
		if Turn_Type == "Move":
			Turn_Type = "Block"
		else:
			Turn = "Player Turn"
	


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
	Signal_Pos = Vector2(y, x)
	New_Button_Signal = true
	print(name)
	print(Signal_Pos)


func _on_board_maker_board_ready() -> void:
	Board_Maker = self.get_child(0)
	print("BoardMaker is ready!")


#endregion

#region TEST_FUNCTIONS


func print_board() -> void:
	for row in Board:
		print(row)


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
