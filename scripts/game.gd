extends Control

@export var MINIMAX_DEPTH: int = 3
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
#var Best_Move: Vector2 = Vector2(-1, -1)
#var Best_Block: Vector2 = Vector2(-1, -1)
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


# Default func
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
		Board.append(new_row.duplicate(true))  # Add the row to the Board
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


func check_move(old_pos: Vector2, new_pos: Vector2, board: Array) -> bool:
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


func check_block(pos: Vector2, board: Array) -> bool:
	# Check if inside board
	
	if not (index_in_bounds(pos.x, 8) and index_in_bounds(pos.y, 8)):
		return false
	# Check if position is empty
	if board[pos.x][pos.y] == 0:
		return true
	else:
		return false

# returns board arrays with moves on them.
func get_all_moves(board: Array, self_pos: Vector2, player: int) -> Array:
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
		if check_move(self_pos, new_pos, board):
			# Create a new board and set the block position to -1
			# Duplicate the current board state
			# This might be HEAVY on the performance.
			var new_board: Array = []
			for row in board:
				new_board.append(row.duplicate(true))
			
			#maybe y-x ?
			new_board[x][y] = 0
			new_board[new_pos.x][new_pos.y] = player
			var new_board_copy: Array = new_board.duplicate(true)
			moves.append(new_board_copy)
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
		if check_block(pos, board):
			# Create a new board and set the block position to -1
			var new_board: Array = []
			for row in board:
				# Duplicate the current board state
				# This might be HEAVY on the performance.
				new_board.append(row.duplicate(true))

			new_board[pos.x][pos.y] = -1
			var new_board_copy: Array = new_board.duplicate(true)
			blocks.append(new_board_copy)

	return blocks


# might be [y][x] test it.
func compare_boards(current_board: Array, new_board: Array) -> Dictionary:
	var changes: Dictionary = {"move": Vector2(-1, -1), "block": Vector2(-1, -1)}
	# Deep copy boards.
	var current_board_copy = current_board.duplicate(true)
	var new_board_copy = new_board.duplicate(true)
	 # Check if boards are valid
	for x in range(8):
		for y in range(8):
			if current_board_copy[x][y] != new_board_copy[x][y]:
				# Check if the position was empty and is now occupied
				if current_board_copy[x][y] == 0 and new_board_copy[x][y] != 0:
					# Determine if it's a move or block based on the value
					if new_board_copy[x][y] == 2:  # Assuming 2 is AI's move
						changes["move"] = Vector2(x, y)
					elif new_board_copy[x][y] == -1:  # Assuming -1 is Block
						changes["block"] = Vector2(x, y)
	
	return changes

'''
# WORKS FAULTY.
# player is 1 for Player, 2 for AI.
func generate_moves(board: Array, self_pos: Vector2, opponent_pos: Vector2, player: int) -> Array:
	var full_move_boards = []
	var move_boards = get_all_moves(board, self_pos, player)
	
	for move_board in move_boards:
		var move_board_copy: Array = move_board.duplicate(true)
		var block_boards = get_all_blocks(move_board_copy, opponent_pos)
		
		for block_board in block_boards:
			var block_board_copy: Array = block_board.duplicate(true)
			print("block board is:")
			print_board(block_board_copy)
			full_move_boards.append(block_board_copy)
		# PROBLEM OCCURS HERE.
		print("NEXT MOVE BOARD")
			
	return full_move_boards
'''

func generate_moves(board: Array, self_pos: Vector2, opponent_pos: Vector2) -> Array:
	var moves: Array = []
	var x = self_pos.x
	var y = self_pos.y
	var player = board[x][y]

	var ox = opponent_pos.x
	var oy = opponent_pos.y
	var opponent = board[ox][oy]

	if not (player == 1 or player == 2):
		push_error("Invalid self_pos in generate_moves")
	elif not (opponent == 1 or opponent == 2):
		push_error("Invalid opponent_pos in generate_moves")
	elif player == opponent:
		push_error("Player and opponent are the same in generate_moves")

	# All possible movement directions
	var directions = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0),
		Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0)
	]

	# Iterate through moves and block placements
	for direction in directions:
		var new_pos = Vector2(x + direction.x, y + direction.y)

		if check_move(self_pos, new_pos, board):
			var moved_board: Array = [] # Create a new board
			for row in board: # Duplicate current board state
				moved_board.append(row.duplicate(true))

			moved_board[x][y] = 0
			moved_board[new_pos.x][new_pos.y] = player

			var final_board = place_blocks_expanding(moved_board, opponent_pos)

			var final_board_copy = final_board.duplicate(true)
			moves.append(final_board_copy)
	return moves

func place_blocks_expanding(board: Array, opponent_pos: Vector2) -> Array:
	var blocks_placed: int = 0
	var new_board: Array = [] # Duplicate the current state
	for row in board:
		new_board.append(row.duplicate(true))

	# Increase radius from 1 till it finds 2 valid positions
	var radius: int = 1
	while blocks_placed < 2 and radius <= 8:
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				var block_pos = Vector2(opponent_pos.x + x, opponent_pos.y + y)
				# Check if position is within bounds and not the opponent
				if index_in_bounds(block_pos.x, 8) and index_in_bounds(block_pos.y, 8) and (block_pos.x != opponent_pos.x or block_pos.y != opponent_pos.y): 
					if check_block(block_pos, new_board): # If it's empty
						new_board[block_pos.x][block_pos.y] = -1 # Place block
						blocks_placed += 1
						if blocks_placed == 2: # Stop once 2 blocks are placed
							break
			if blocks_placed == 2:
				break
		if blocks_placed < 2: # If not enough blocks were placed, increase radius
			radius += 1
	return new_board


# SHOULD ALSO GIVE THE BEST MOVE.
# Test this.
# GIGANTIC recursive function. Check performance issues.
func minimax(max_pos: Vector2, min_pos: Vector2, board: Array, depth: int, alpha: int, beta: int, maximizingPlayer: bool) -> int:
	# initial call minimax(currentPosition, 3, -INF, +INF, true)
	# initial call minimax(AI_Pos, Player_Pos, move_board, MINIMAX_DEPTH, -INF, INF, true)
	if depth == 0 or check_victory(board) != 0:
		var a: int = calculate_minimax_points(max_pos, min_pos, board)
		#print("Reached base case at depth: ", depth)
		#print("Reached base case with eval: ", a)
		return a
	if maximizingPlayer:
		var moves: Array = generate_moves(board, max_pos, min_pos)
		var maxEval: int = -INF 
		
		for move in moves:
			var move_copy: Array = move.duplicate(true)
			var eval: int = minimax(max_pos, min_pos, move_copy, depth - 1, alpha, beta, false)
			if eval > maxEval:
				maxEval = eval
			alpha = max(alpha, eval)
			if beta <= alpha:
				break
		return maxEval
	else:
		var moves: Array = generate_moves(board, min_pos, max_pos)
		var minEval: int = INF
		
		for move in moves:
			var move_copy: Array = move.duplicate(true)
			var eval: int = minimax(max_pos, min_pos, move_copy, depth - 1, alpha, beta, true)
			if eval < minEval:
				minEval = eval
			beta = min(beta, eval)
			if beta <= alpha:
				break
		return minEval


# Modified minimax function
func minimax2(board, ai_pos, player_pos, depth, alpha, beta, maximizingPlayer):
	if depth == 0 or check_victory(board) != 0:
		var eval = calculate_minimax_points(ai_pos, player_pos, board)
		return { "eval": eval, "move": null, "block":null }  # No move at leaf nodes

	var best_move = null
	var best_block = null
	if maximizingPlayer:
		var maxEval = -INF

		var moves = get_all_moves(board, ai_pos, 2) # get all moves
		for move_data in moves:
			var evalResult = minimax(move_data["board"], move_data["ai_pos"], player_pos, depth - 1, alpha, beta, false)
			if evalResult.eval > maxEval:
				maxEval = evalResult.eval
				best_move = move_data["move"]
				best_block = move_data["block"]

			alpha = max(alpha, evalResult.eval) #Here
			if beta <= alpha:
				break # pruning

		return { "eval": maxEval, "move": best_move, "block": best_block }

	else:  # Minimizing player... same logic as maximizing...
		var minEval = INF

		var moves = get_all_moves(board, player_pos, 1) # get all moves
		for move_data in moves:
			var evalResult = minimax(move_data["board"], ai_pos, player_pos, depth - 1, alpha, beta, true)
			if evalResult.eval < minEval:
				minEval = evalResult.eval
				best_move = move_data["move"]
				best_block = move_data["block"]

			beta = min(beta, evalResult.eval) #Here
			if beta <= alpha:
				break # pruning

		return { "eval": minEval, "move": best_move, "block": best_block }



func calculate_minimax_points(max_pos: Vector2, min_pos: Vector2, board: Array) -> int:
	# returns the difference between self position (max_pos) and player position (min_pos)
	# Calculated by the amount of free blocks around each player.
	var board_copy = board.duplicate(true)
	var self_mobility: int = calculate_position(max_pos.x, max_pos.y, board_copy)
	var opponent_mobility: int = calculate_position(min_pos.x, min_pos.y, board_copy)
	var points: int = self_mobility - opponent_mobility
	return points


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
	var board_copy = board.duplicate(true)
	var points: int = 0
	# Check if the given position is valid
	# Maybe add mobility value too.
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
			if index_in_bounds(x, 8) and index_in_bounds(y, 8) and board_copy[x][y] == 0:
				points += 1
	
	return points

# Helper function to check if an index is within bounds
func index_in_bounds(index: int, size: int) -> bool:
	return index >= 0 and index < size


# This func may just call Victory func and return nothing at all.
func check_victory(board) -> int:
	var board_copy: Array = board.duplicate(true)
	var player_victory: int = calculate_position(Player_Pos.x, Player_Pos.y, board_copy)
	var AI_victory: int = calculate_position(AI_Pos.x, AI_Pos.y, board_copy)
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


func ai_play():
	var best_score: int = -INF
	var best_board: Array = []
	var best_move: Vector2
	var best_block: Vector2
	
	var moves_bank = generate_moves(Board, AI_Pos, Player_Pos)
	
	for move_board in moves_bank:
		#print("current move board:" )
		#print_board(move_board)
		var score = minimax(AI_Pos, Player_Pos, move_board, MINIMAX_DEPTH, -INF, INF, false)
		if score >= best_score:
			best_board = []
			best_score = score
			for row in move_board:
				best_board.append(row.duplicate(true))

			
	# APPLY BEST MOVE
	var changes = compare_boards(Board, best_board)
	best_move = changes["move"]
	best_block = changes["block"]
	
	var ai_pos_string :String = vector2_to_string(AI_Pos)
	var best_move_string :String= vector2_to_string(best_move)
	var best_block_string :String = vector2_to_string(best_block)
	move_AI(best_move)
	move_icon(Board_Maker.get_node(ai_pos_string), Board_Maker.get_node(best_move_string))
	
	
	if check_victory(Board) == 2:
		defeat()

	place_block(Board_Maker.get_node(best_block_string), best_block)

	# Check if opponent has any moves after
	if check_victory(Board) == 2:
		defeat()
	else:
		change_turn()


'''
func ai_play():
	var eval = minimax(AI_Pos, Player_Pos, Board, 3, -INF, +INF, true)
	
	var ai_pos_string :String = vector2_to_string(AI_Pos)
	var best_move_string :String= vector2_to_string(Best_Move)
	var best_block_string :String = vector2_to_string(Best_Block)
	# Move button icons
	print ("Turn Number: ", Turn_Number)
	print ("eval is ", eval)
	print ("ai_pos_string:", ai_pos_string)
	print ("Final Best Move is:", best_move_string)
	print ("Final Best Block is:", best_block_string)
	
	
	move_icon(Board_Maker.get_node(ai_pos_string), Board_Maker.get_node(best_move_string))
	move_AI(Best_Move)
	
	if check_victory() == 2:
		defeat()
	
	place_block(Board_Maker.get_node(best_block_string), Best_Block)
	
	# Check if opponent has any moves after
	if check_victory() == 2:
		defeat()
	else:
		change_turn()
'''

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
		if check_move(Player_Pos, Signal_Pos, Board):
			
			# Move player on Board
			move_player(Signal_Pos)
			# Move button icons
			move_icon(Board_Maker.get_node(player_pos_string), Board_Maker.get_node(new_pos_string), Signal_Pos)
			
			# Check if opponent has any moves after
			if check_victory(Board) == 1:
				victory()
			else:
				change_turn()
	else:
		if check_block(Signal_Pos, Board):
			place_block(Board_Maker.get_node(new_pos_string), Signal_Pos)
			
			# Check if opponent has any moves after
			if check_victory(Board) == 1:
				victory()
			else:
				change_turn()


func _on_board_maker_board_ready() -> void:
	Board_Maker = self.get_child(0)
	print("BoardMaker is ready!")


#endregion

#region TEST_FUNCTIONS


func print_board(board: Array = Board) -> void:
	for row in board:
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
		[0, -1, 0, 0, 0, 0, 0, 0],
		[-1, 1, 0, -1, 0, 2, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, -1, 1, 1, 2, 0, -1, 0],
		[0, 0, 1, 2, 1, 0, 0, 0],
		[0, 2, 1, 1, 1, 0, 0, 0],
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
	print("Test Case 8 - On AI (3,4): Expected: 4, Got:", calculate_position(4, 3, test_board))

#endregion
