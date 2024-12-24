extends Control

# The Board
var Board: Array = []
#
# 0 - Empty Squares
# 1 - Player 
# 2 - AI
# -1 - Blocked Squares
#
# Can be "Player Turn" or "AI Turn"
var Turn: String = "Player Turn"
# Can be "Move" or "Block"
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
# Best current moves for the AI.
var best_move: Vector2 = Vector2(-1, -1)
var best_block: Vector2 = Vector2(-1, -1)
var Turn_Number: int = 1

# Default func called when node enters the scene. (on load)
func _ready() -> void:
	
	# Wait until buttons are ready.
	while Board_Maker == null:
		continue
		
	initiate_board()
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
		print ("First Turn is ", Turn)
		toggle_buttons(Board_Maker, true)
	elif first_turn == 0:
		Turn = "AI Turn"
		print ("First Turn is ", Turn)
		toggle_buttons(Board_Maker, false)
		ai_play()



# Useless implementation. Just move it to _ready in the future.
func run_game() -> void:
	test_calculate_position3()
	determine_first_turn()
	# USE SIGNALS INSTEAD.
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


func vector2_to_string(vec: Vector2) -> String:
	return str(vec.x) + "-" + str(vec.y)


# Not using the last parameter. Find out what that was.
func move_icon(old_pos :Node, new_pos: Node, on_board_new_pos: Vector2 = Vector2(-1,-1)):
	# Handle Button icons for positions
	#print("old_pos.name: ", old_pos.name)
	#print("new_pos.name: ", new_pos.name)
	var old_pos_icon = old_pos.get_button_icon()
	var new_pos_icon = new_pos.get_button_icon()
	old_pos.set_button_icon(new_pos_icon)
	new_pos.set_button_icon(old_pos_icon)


func move_player(new_pos: Vector2):
	# Move on Board
	Board[Player_Pos.x][Player_Pos.y] = 0
	Board[new_pos.x][new_pos.y] = 1
	Player_Pos = new_pos


func move_AI(new_pos: Vector2):
	# Move on Board
	Board[AI_Pos.x][AI_Pos.y] = 0
	Board[new_pos.x][new_pos.y] = 1
	AI_Pos = new_pos


func place_block(pos: Node, on_board_pos: Vector2):
	# Should be similar to move_player.
	# Set Icon
	var block_icon = Board_Maker.get_node("block").get_button_icon()
	pos.set_button_icon(block_icon)
	Board[on_board_pos.x][on_board_pos.y] = -1


func check_move(old_pos: Vector2, new_pos: Vector2, board: Array = Board) -> bool:
	# Check if inside board
	if not (index_in_bounds(new_pos.x, 8) and index_in_bounds(new_pos.y, 8)):
		return false
	# Check if empty
	if board[new_pos.x][new_pos.y] != 0:
		return false
	# Check if within 1 range
	var delta_x = abs(new_pos.x - old_pos.x)
	var delta_y = abs(new_pos.y - old_pos.y)
	#print ("checkmove is " , (delta_x <= 1 and delta_y <= 1))
	return delta_x <= 1 and delta_y <= 1


func check_block(pos: Vector2, board: Array = Board) -> bool:
	# Check if inside board
	if not (index_in_bounds(pos.x, 8) and index_in_bounds(pos.y, 8)):
		return false
	# Check if position is empty
	if board[pos.x][pos.y] == 0:
		return true
	else:
		return false

# returns board arrays with moves on them.
func get_all_moves(board: Array, self_pos: Vector2, turn: int) -> Array:
	var moves: Array = []
	var x = self_pos.x
	var y = self_pos.y
	
	# All possible movement directions
	var directions = [
		Vector2(-1, 0),
		Vector2(1, 0),
		Vector2(0, -1),
		Vector2(0, 1),
		Vector2(-1, -1),
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2(1, 1)
	]

	for direction in directions:
		var new_pos = Vector2(x + direction.x, y + direction.y)
		if check_move(self_pos, new_pos):
			# Create a new board and set the block position to -1
			var new_board: Array = []
			for row in board:
				# Duplicate the current board state
				# This might be HEAVY on the performance.
				new_board.append(row.duplicate())

			new_board[new_pos.x][new_pos.y] = turn
			moves.append(new_board)
	return moves

# DOES NOT get all blocks. Only blocks near opponent.
# AI should always put their blocks near player.
# This logic may change.
# Returns board arrays with blocks on them.
func get_all_blocks(board: Array, opponent_pos: Vector2) -> Array:
	var blocks: Array = []
	var x = opponent_pos.x
	var y = opponent_pos.y
	
	# All possible block directions
	var directions = [
		Vector2(-1, 0),
		Vector2(1, 0),
		Vector2(0, -1),
		Vector2(0, 1),
		Vector2(-1, -1),
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2(1, 1)
	]
	
	for direction in directions:
		var pos = Vector2(x + direction.x, y + direction.y)
		if check_block(pos):
			# Create a new board and set the block position to -1
			var new_board: Array = []
			for row in board:
				# Duplicate the current board state
				# This might be HEAVY on the performance.
				new_board.append(row.duplicate())

			new_board[pos.x][pos.y] = -1
			blocks.append(new_board)

	return blocks


# might be [y][x] test it.
func compare_boards(current_board: Array, new_board: Array) -> Dictionary:
	var changes: Dictionary = {"move": Vector2(-1, -1), "block": Vector2(-1, -1)}
	
	for x in range(8):
		for y in range(8):
			if current_board[x][y] != new_board[x][y]:
				# Check if the position was empty and is now occupied
				if current_board[x][y] == 0 and new_board[x][y] != 0:
					# Determine if it's a move or block based on the value
					if new_board[x][y] == 2:  # Assuming 2 is AI's move
						changes["move"] = Vector2(x, y)
					elif new_board[x][y] == -1:  # Assuming -1 is Block
						changes["block"] = Vector2(x, y)
	
	return changes


# SHOULD ALSO GIVE THE BEST MOVE.
# Test this.
# GIGANTIC recursive function. Check performance issues.
func minimax(max_pos: Vector2, min_pos: Vector2, board: Array, depth: int, alpha: int, beta: int, maximizingPlayer: bool) -> int:
	# initial call minimax(currentPosition, 3, -INF, +INF, true)
	#print("Entered minimax depth: ", depth)
	if depth == 0 or check_victory() == 1 or check_victory() == 2:
		var a = calculate_minimax_points(max_pos, min_pos, board)
		#print("minimax points: ", a)
		#print("Exited minimax depth: ", depth)
		return a
	if maximizingPlayer:
		var maxEval = -INF  # Initialize max evaluation to negative infinity
		var current_best_move: Vector2 = Vector2(-1, -1)  # Local variable for the best move
		var current_best_block: Vector2 = Vector2(-1, -1)  # Local variable for the best block
		var move_boards: Array = get_all_moves(board, max_pos, 2)  # All "Move" moves.
		for move_board in move_boards:
			var block_boards = get_all_blocks(move_board, min_pos)
			for block_board in block_boards:
				var eval = minimax(max_pos, min_pos, block_board, depth - 1, alpha, beta, false)
				#print ("eval: ", eval)
				if eval > maxEval:
					
					maxEval = eval
					#print("maxEval: ", maxEval)
					var changes = compare_boards(board, block_board)  # Compare current board with new block board
					
					current_best_move = changes["move"]
					current_best_block = changes["block"]
					#print ("current_best_move: ", current_best_move)
					#print ("current_best_block: ", current_best_block)
				alpha = max(alpha, eval)
				if beta <= alpha:
					break
		# Update global best moves if a better evaluation was found
		if current_best_move != Vector2(-1, -1):
			best_move = current_best_move
			best_block = current_best_block
		#print("Exited minimax depth: ", depth)
		return maxEval  # Return the best evaluation found for maximizing player
	else:
		var minEval = INF  # Initialize min evaluation to positive infinity
		var current_best_move: Vector2 = Vector2(-1, -1)  # Local variable for the best move
		var current_best_block: Vector2 = Vector2(-1, -1)  # Local variable for the best block
		var move_boards: Array = get_all_moves(board, min_pos, 1)  # All "Move" moves.
		for move_board in move_boards:
			var block_boards = get_all_blocks(move_board, max_pos)
			for block_board in block_boards:
				var eval = minimax(max_pos, min_pos, block_board, depth - 1, alpha, beta, true)
				#print ("eval: ", eval)
				if eval < minEval:
					minEval = eval
					#print("minEval: ", minEval)
					var changes = compare_boards(board, block_board)  # Compare current board with new block board
					#current_best_move = changes["move"]
					#current_best_block = changes["block"]
				beta = min(beta, eval)
				if beta <= alpha:
					break
		# Update global best moves if a better evaluation was found
		if current_best_move != Vector2(-1, -1):
			best_move = current_best_move
			best_block = current_best_block
		#print("Exited minimax depth: ", depth)
		return minEval  # Return the best evaluation found for minimizing player



func calculate_minimax_points(max_pos: Vector2, min_pos: Vector2, board: Array) -> int:
	# returns the difference between self position (max_pos) and player position (min_pos)
	# Calculated by the amount of free blocks around each player.
	return calculate_position(max_pos.x, max_pos.y, board) - calculate_position(min_pos.x, min_pos.y, board)


func toggle_buttons(parent: Node, is_turn: bool):
	# Toggle each button
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
			Turn_Number += 1
			Turn = "AI Turn"
			toggle_buttons(Board_Maker, false)
			ai_play()
	else:
		Turn_Number += 1
		Turn = "Player Turn"
		Turn_Type = "Move"
		toggle_buttons(Board_Maker, true)
		#toggle_buttons(Board_Maker, false)
		##ai_play()
		#if Turn_Type == "Move":
			#Turn_Type = "Block"
		#else:
			#Turn = "Player Turn"
			#toggle_buttons(Board_Maker, true)


func calculate_position(boardPosX: int, boardPosY: int, board: Array) -> int:
	var points: int = 0
	# Check if the given position is valid
	if not index_in_bounds(boardPosX, 8) or not index_in_bounds(boardPosY, 8):
		return 0
	
	# Check all adjacent and diagonal positions
	for i in range(-1, 2):
		for j in range(-1, 2):
			# Skip the center position (the position itself)
			if i == 0 and j == 0:
				continue
			
			var x = boardPosX + i
			var y = boardPosY + j
			
			# Check if the position is within bounds and empty
			if index_in_bounds(x, 8) and index_in_bounds(y, 8) and board[x][y] == 0:
				points += 1
	
	return points

# Helper function to check if an index is within bounds
func index_in_bounds(index: int, size: int) -> bool:
	return index >= 0 and index < size


# This func may just call Victory func and return nothing at all.
func check_victory() -> int:
	var player_victory: int = calculate_position(Player_Pos.x, Player_Pos.y, Board)
	var AI_victory: int = calculate_position(AI_Pos.x, AI_Pos.y, Board)
	if player_victory <= 0:
		print ("DEFEAT ", player_victory)
		return 2 # AI Victory
	elif AI_victory <= 0:
		print ("VICTORY ", AI_victory)
		return 1 # Player Victory
	else:
		return 0 # Playable


func victory():
	toggle_buttons(Board_Maker, false)
	# Make victory pop up visible
	pass


func defeat():
	toggle_buttons(Board_Maker, false)
	# Make defeat pop up visible
	pass


# Default func
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func ai_play():
	var eval = minimax(AI_Pos, Player_Pos, Board, 5, -INF, +INF, true)
	
	var ai_pos_string :String = vector2_to_string(AI_Pos)
	var new_pos_string :String= vector2_to_string(best_move)
	var new_block_string :String = vector2_to_string(best_block)
	# Move button icons
	print ("Turn Number: ", Turn_Number)
	print ("eval is ", eval)
	print ("ai_pos_string:", ai_pos_string)
	print ("new_pos_string:", new_pos_string)
	print ("new_block_string:", new_block_string)
	move_icon(Board_Maker.get_node(ai_pos_string), Board_Maker.get_node(new_pos_string))
	move_AI(best_move)
	place_block(Board_Maker.get_node(new_block_string), best_block)

	# Check if opponent has any moves after
	if check_victory() == 2:
		defeat()
	else:
		change_turn()


#region SIGNALS

# Button Pressed signal form BoardMaker.
# Probably won't need y,x parameters.
func _on_board_maker_send_location(name, y, x) -> void:
	Signal_Pos = Vector2(y, x)
	#New_Button_Signal = true
	print("Player Clicked: ", name)
	#print("signal pos: ", Signal_Pos)
	# Stringify the vectors so they can reach buttons.
	var player_pos_string = vector2_to_string(Player_Pos)
	var new_pos_string = vector2_to_string(Signal_Pos)
	if Turn_Type == "Move":
		if check_move(Player_Pos, Signal_Pos):
			# Move button icons
			move_icon(Board_Maker.get_node(player_pos_string), Board_Maker.get_node(new_pos_string), Signal_Pos)
			# Move player on Board
			move_player(Signal_Pos)
			
			
			# Check if opponent has any moves after
			if check_victory() == 1:
				victory()
			else:
				change_turn()
	else:
		if check_block(Signal_Pos):
			place_block(Board_Maker.get_node(new_pos_string), Signal_Pos)
			
			# Check if opponent has any moves after
			if check_victory() == 1:
				victory()
			else:
				change_turn()


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
	
func test_calculate_position2():
	var test_board = [
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 1, 0, -1, 0, 2, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, -1, 0, 1, 2, 0, -1, 0],
		[0, 0, 0, 2, 1, 0, 0, 0],
		[0, 2, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, -1, 0, 1, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0]
	]

	# Test case 1: Corner position (0,0)
	print("Test Case 1 - Corner (0,0): Expected: 2, Got:", calculate_position(0, 0, test_board))

	# Test case 2: Edge position (0,3)
	print("Test Case 2 - Edge (0,3): Expected: 4, Got:", calculate_position(0, 3, test_board))

	# Test case 3: Center position (3,3)
	print("Test Case 3 - Center (3,3): Expected: 5, Got:", calculate_position(3, 3, test_board))

	# Test case 4: Position surrounded by some blocks (1,1)
	print("Test Case 4 - Near blocks (1,1): Expected: 8, Got:", calculate_position(1, 1, test_board))

	# Test case 5: Position with maximum free space (2,2)
	print("Test Case 5 - Max free space (2,2): Expected: 8, Got:", calculate_position(2, 2, test_board))

	# Test case 6: Position on a block (-1) (3,6)
	print("Test Case 6 - On block (3,6): Expected: 0, Got:", calculate_position(3, 6, test_board))

	# Test case 7: Position on player (1) (3,3)
	print("Test Case 7 - On player (3,3): Expected: 3, Got:", calculate_position(3, 3, test_board))

	# Test case 8: Position on AI (2) (3,4)
	print("Test Case 8 - On AI (3,4): Expected: 4, Got:", calculate_position(3, 4, test_board))


func test_calculate_position3():
	var test_board = [
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 1, 0, -1, 0, 2, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, -1, 0, 1, 2, 0, -1, 0],
		[0, 0, 0, 2, 1, 0, 0, 0],
		[0, 2, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, -1, 0, 1, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0]
	]

	# Test case 1: Corner position (0,0)
	print("Test Case 1 - Corner (0,0): Expected: 3, Got:", calculate_position(0, 0, test_board))

	# Test case 2: Edge position (0,3)
	print("Test Case 2 - Edge (0,3): Expected: 4, Got:", calculate_position(0, 3, test_board))

	# Test case 3: Center position (3,3)
	print("Test Case 3 - Center (3,3): Expected: 3, Got:", calculate_position(3, 3, test_board))

	# Test case 4: Position surrounded by some blocks (1,1)
	print("Test Case 4 - Near blocks (1,1): Expected: 5, Got:", calculate_position(1, 1, test_board))

	# Test case 5: Position with maximum free space (2,2)
	print("Test Case 5 - Max free space (2,2): Expected: 8, Got:", calculate_position(2, 2, test_board))

	# Test case 6: Position on a block (-1) (3,6)
	print("Test Case 6 - On block (3,6): Expected: 0, Got:", calculate_position(3, 6, test_board))

	# Test case 7: Position on player (1) (3,3)
	print("Test Case 7 - On player (3,3): Expected: 3, Got:", calculate_position(3, 3, test_board))

	# Test case 8: Position on AI (2) (3,4)
	print("Test Case 8 - On AI (3,4): Expected: 4, Got:", calculate_position(3, 4, test_board))

#endregion
