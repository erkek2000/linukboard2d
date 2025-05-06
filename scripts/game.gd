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
# Can be "Move" or "Block1" or "Block2"
var Turn_Type: String = "Move"
# Gives Player Position, updated once every turn.
var Player_Pos: Vector2
# Gives AI Position, updated once every turn.
var AI_Pos: Vector2
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
	#test_place_blocks_loop()
	# Wait until buttons are ready. LOADING TIME
	
	await get_tree().create_timer(0.1).timeout
	while Board_Maker == null:
		continue

	print("minimax depth is ", GameData.MINIMAX_DEPTH)
	
	initiate_board()
	#run_game() # No longer needed.
	# LOAD TIME - AI move calculations freeze board render otherwise.
	await get_tree().create_timer(1.0).timeout
	
	determine_first_turn()
	
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
	
	if GameData.CENTER_POS:
		Player_Pos = Vector2(4, 3)
		AI_Pos = Vector2(3, 4)
		Board[4][3] = 1 # Player
		Board[3][4] = 2 # AI
	else:
		Player_Pos = Vector2(7, 3)
		AI_Pos = Vector2(0, 4)
		Board[7][3] = 1 # Player
		Board[0][4] = 2 # AI


func determine_first_turn() -> void:
	var first_turn : int = randi() % 2
	if first_turn == 1:
		Board_Maker.turn_label.text = "Your Turn"
		Turn = "Player Turn"
		print ("First Turn is ", Turn)
		toggle_buttons(Board_Maker, true)
	elif first_turn == 0:
		Board_Maker.turn_label.text = "AI is playing..."
		await get_tree().create_timer(0.1).timeout
		Turn = "AI Turn"
		print ("First Turn is ", Turn)
		toggle_buttons(Board_Maker, false)
		ai_play()



# Useless implementation. Just move it to _ready in the future.
func run_game() -> void:
	
	#test_calculate_position3()
	
	#determine_first_turn()
	
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
func move_icon(old_pos: Node, new_pos: Node, on_board_new_pos: Vector2):
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
	Board[new_pos.x][new_pos.y] = 2
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

# NEVER USED
func get_square_at(pos: Vector2, index: int) -> Vector2:
	var directions: Array = [
		Vector2(-1, -1),  # 0: Top-left
		Vector2(0, -1),   # 1: Top
		Vector2(1, -1),   # 2: Top-right
		Vector2(1, 0),    # 3: Right
		Vector2(1, 1),    # 4: Bottom-right
		Vector2(0, 1),    # 5: Bottom
		Vector2(-1, 1),   # 6: Bottom-left
		Vector2(-1, 0)    # 7: Left
	]
	
	if index < 0 or index > 7:
		push_error("get_square_at called with invalid index: ", index)
		return pos
	
	return pos + directions[index]




'''
# Returns a list of move_data dictionaries, each containing:
# - "board": the board state after the move and blocks
# - "move": the position the player moved to
# - "block1": the position of the first block
# - "block2": the position of the second block
func generate_moves(board: Array, self_pos: Vector2, opponent_pos: Vector2) -> Array:
	var all_plays = []
	
	# Step 1: Generate all possible moves
	var possible_moves = []
	var x = self_pos.x
	var y = self_pos.y
	var player = board[x][y]
	
	# All possible movement directions
	var directions = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0),
		Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0)
	]
	
	# Generate all valid moves
	for direction in directions:
		var new_pos = Vector2(x + direction.x, y + direction.y)
		if check_move(self_pos, new_pos, board):
			# Create a new board with the move applied
			var moved_board = []
			for row in board:
				moved_board.append(row.duplicate(true))
			
			moved_board[x][y] = 0
			moved_board[new_pos.x][new_pos.y] = player
			
			# Add to possible moves
			possible_moves.append({
				"board": moved_board,
				"move": new_pos
			})
			
	
	
	# Step 2: For each move, generate all possible block placements
	for move_data in possible_moves:
		var moved_board = move_data["board"]
		var move_pos = move_data["move"]
		
		# Get all possible block positions around opponent
		var block_positions = get_block_positions_around(moved_board, opponent_pos)
		
		# If no blocks can be placed, opponent is cornered (win condition)
		if block_positions.size() == 0:
			all_plays.append({
				"board": moved_board,
				"move": move_pos,
				"block1": Vector2(-1, -1),
				"block2": Vector2(-1, -1),
				"victory": true
			})
			continue
		
		# If only one block can be placed
		if block_positions.size() == 1:
			var block_pos = block_positions[0]
			var blocked_board = []
			for row in moved_board:
				blocked_board.append(row.duplicate(true))
			
			blocked_board[block_pos.x][block_pos.y] = -1
			
			all_plays.append({
				"board": blocked_board,
				"move": move_pos,
				"block1": block_pos,
				"block2": Vector2(-1, -1),
				"victory": true
			})
			continue
		
		# Generate all combinations of 2 blocks from available positions
		for i in range(block_positions.size()):
			for j in range(i + 1, block_positions.size()):
				var block1 = block_positions[i]
				var block2 = block_positions[j]
				
				# Create a new board with blocks placed
				var blocked_board = []
				for row in moved_board:
					blocked_board.append(row.duplicate(true))
				
				blocked_board[block1.x][block1.y] = -1
				blocked_board[block2.x][block2.y] = -1
				
				
				# Add this play to our list
				
				all_plays.append({
					"board": blocked_board,
					"move": move_pos,
					"block1": block1,
					"block2": block2
				})
				if GameData.DEBUG:
					print("Found ", all_plays.size(), " valid full ", player, " moves with the board:")
					print_board(blocked_board)
	
	return all_plays

# Helper function to get all possible block positions around an opponent
func get_block_positions_around(board: Array, opponent_pos: Vector2) -> Array:
	var block_positions = []
	var ox = opponent_pos.x
	var oy = opponent_pos.y
	
	# Check all adjacent and diagonal positions
	for i in range(-1, 2):
		for j in range(-1, 2):
			# Skip the center position (the opponent position)
			if i == 0 and j == 0:
				continue
			
			var block_pos = Vector2(ox + i, oy + j)
			
			# Check if the position is valid for a block
			if check_block(block_pos, board):
				block_positions.append(block_pos)
	
	return block_positions


# alpha is the best score the maximizer can guarantee so far.
# beta is the best score the minimizer can guarantee so far

func minimax(board: Array, ai_pos: Vector2, player_pos: Vector2, depth: int, alpha: int, beta: int, maximizing_player: bool) -> Dictionary:
	# Terminal conditions: depth reached or victory detected
	if depth == 0 or check_victory(ai_pos, player_pos, board) != 0:
		if GameData.DEBUG:
			print("End condition reached with board:")
			print("############")
			print_board(board)
			print("############")
		return {
			"eval": calculate_minimax_points(ai_pos, player_pos, board),
			"move": Vector2(-1, -1),
			"block1": Vector2(-1, -1),
			"block2": Vector2(-1, -1)
		}
	
	if maximizing_player:  # AI's turn (maximizing)
		var maxEval = -INF
		var best_move = Vector2(-1, -1)
		var best_block1 = Vector2(-1, -1)
		var best_block2 = Vector2(-1, -1)
		
		# Generate all possible moves for AI
		var moves = generate_moves(board, ai_pos, player_pos)
		
		for move_data in moves:
			# Update AI position for recursive call
			var new_ai_pos = move_data["move"]
			
			# Recursive minimax call
			var evalResult = minimax(
				move_data["board"], 
				new_ai_pos,
				player_pos, 
				depth - 1, 
				alpha, 
				beta, 
				false
			)
			
			if evalResult["eval"] > maxEval:
				maxEval = evalResult["eval"]
				best_move = move_data["move"]
				best_block1 = move_data["block1"]
				best_block2 = move_data["block2"]
			
			# Alpha-Beta pruning
			if GameData.PRUNING:
				alpha = max(alpha, evalResult["eval"])
				if beta <= alpha:
					break
		
		return {
			"eval": maxEval,
			"move": best_move,
			"block1": best_block1,
			"block2": best_block2
		}
		
	else:  # Player's turn (minimizing)
		var minEval = INF
		var best_move = Vector2(-1, -1)
		var best_block1 = Vector2(-1, -1)
		var best_block2 = Vector2(-1, -1)
		
		# Generate all possible moves for Player
		var moves = generate_moves(board, player_pos, ai_pos)
		
		for move_data in moves:
			# Update player position for recursive call
			var new_player_pos = move_data["move"]
			
			# Recursive minimax call
			var evalResult = minimax(
				move_data["board"], 
				ai_pos,
				new_player_pos, 
				depth - 1, 
				alpha, 
				beta, 
				true
			)
			
			if evalResult["eval"] < minEval:
				minEval = evalResult["eval"]
				best_move = move_data["move"]
				best_block1 = move_data["block1"]
				best_block2 = move_data["block2"]
			
			# Alpha-Beta pruning
			if GameData.PRUNING:
				beta = min(beta, evalResult["eval"])
				if beta <= alpha:
					break
		
		return {
			"eval": minEval,
			"move": best_move,
			"block1": best_block1,
			"block2": best_block2
		}
'''


#  Victory cases with single blocks not handled MAYBE
func generate_moves(board: Array, self_pos: Vector2, opponent_pos: Vector2, move_index: int = 0) -> Dictionary:
	# Directions for movement: diagonal and orthogonal
	var directions: Array = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0),
		Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0)
	]
	
	# Split move_index into movement and blocking components
	var move_dir_idx: int = (move_index / 64) % 8 
	var block1_idx: int = (move_index / 8) % 8
	var block2_idx: int = move_index % 8 
	
	# Get player info
	var x: int = self_pos.x
	var y: int = self_pos.y
	var player: int = board[x][y]
	
	# Get movement direction
	var direction: Vector2 = directions[move_dir_idx]
	var new_pos = Vector2(x + direction.x, y + direction.y)
	
	# If this move is invalid, skip to next move
	if not check_move(self_pos, new_pos, board):
		return {
			"completed": 0,
			"next_index": move_index + 64
		}
	
	# Create board with move applied
	var moved_board: Array = board.duplicate(true)
	moved_board[x][y] = 0
	moved_board[new_pos.x][new_pos.y] = player
	
	# Calculate first block position
	var block1_dir: Vector2 = directions[block1_idx]
	var block1_pos: Vector2 = Vector2(opponent_pos.x + block1_dir.x, opponent_pos.y + block1_dir.y)
	
	# If first block position is invalid, try next block position
	if not check_block(block1_pos, moved_board):
		return {
			"completed": 1, 
			"next_index": move_index + 8,
			"board": moved_board,
			"move": new_pos
		}
	# fixed from "next_index": move_index + 8 - (move_index % 8)
	
	# Apply first block
	moved_board[block1_pos.x][block1_pos.y] = -1
	
	# Calculate second block position
	var block2_dir = directions[block2_idx]
	var block2_pos = Vector2(opponent_pos.x + block2_dir.x, opponent_pos.y + block2_dir.y)
	
	# If second block position is invalid, try next second block
	if (not check_block(block2_pos, moved_board)) or block1_pos == block2_pos:
		return {
			"completed": 2,
			"next_index": move_index + 1,
			"board": moved_board,
			"move": new_pos,
			"block1": block1_pos
		}
		# MIGHT BE +64 ########################################
	# fixed from "next_index": move_index + 64
	
	# Apply second block
	moved_board[block2_pos.x][block2_pos.y] = -1
	
	# Return move data with next index
	return {
		"completed": 3,
		"next_index": move_index + 1,
		"board": moved_board,
		"move": new_pos,
		"block1": block1_pos,
		"block2": block2_pos
	}

# alpha is the best score the maximizer can guarantee so far.
# beta is the best score the minimizer can guarantee so far
func minimax(board: Array, ai_pos: Vector2, player_pos: Vector2, depth: int, alpha: int, beta: int, maximizing_player: bool) -> Dictionary:
	# Terminal conditions: depth reached or victory detected
	if depth == 0 or check_victory(ai_pos, player_pos, board, maximizing_player) != 0:
		var eval: int = calculate_minimax_points(ai_pos, player_pos, board, maximizing_player)
		return {
			"eval": eval,
			"move": Vector2(-1, -1),
			"block1": Vector2(-1, -1),
			"block2": Vector2(-1, -1)
		}
	
	if maximizing_player:  # AI's turn (maximizing)
		var maxEval: int = -9223372036854775800
		var best_move: Vector2 = Vector2(-1, -1)
		var best_block1: Vector2 = Vector2(-1, -1)
		var best_block2: Vector2 = Vector2(-1, -1)
		
		# Start generating moves incrementally
		var move_index: int = 0
		var max_index: int = 512  # Reasonable limit to prevent freezing
		
		while move_index < max_index:
			
			var move_result = generate_moves(board, ai_pos, player_pos, move_index)
			
			if GameData.DEBUG:
				var move_dir_idx: int = (move_index / 64) % 8 
				var block1_idx: int = (move_index / 8) % 8
				var block2_idx: int = move_index % 8 
				print(depth, " depth, checking position in AI: ", move_dir_idx, block1_idx, block2_idx)
				
			
			if move_result["completed"] == 3:
				var evalResult = minimax(
					move_result["board"], 
					move_result["move"], 
					player_pos, 
					depth - 1, 
					alpha, 
					beta, 
					false
				)
				#print("eval is ", evalResult["eval"], " maxeval is: ", maxEval)
				if evalResult["eval"] > maxEval:
					#print(evalResult["eval"], " is bigger than ", maxEval)
					maxEval = evalResult["eval"]
					best_move = move_result["move"]
					best_block1 = move_result["block1"]
					best_block2 = move_result["block2"]
				# Alpha-Beta pruning
				if GameData.PRUNING:
					alpha = max(alpha, evalResult["eval"])
					if beta <= alpha :#and best_move != Vector2(-1, -1):
						break
			elif move_result["completed"] > 0:
				# May call minimax depth 0 instead:
				var victory : int = check_victory(move_result["move"], player_pos, move_result["board"], maximizing_player)
				if victory == 2:
					if move_result["completed"] == 2:
						return {
							"eval" : 100000,
							"move" : move_result["move"],
							"block1" : move_result["block1"],
							"block2": Vector2(-1, -1)
						}
					if move_result["completed"] == 1:
						return {
							"eval" : 100000,
							"move" : move_result["move"],
							"block1" : Vector2(-1, -1),
							"block2": Vector2(-1, -1)
						}
				elif victory == 1:
					if move_result["completed"] == 1:
						return {
								"eval" : -100000,
								"move" : move_result["move"],
								"block1" : move_result["block1"],
								"block2": Vector2(-1, -1)
						}
					if move_result["completed"] == 2:
						return {
							"eval" : -100000,
							"move" : move_result["move"],
							"block1" : Vector2(-1, -1),
							"block2": Vector2(-1, -1)
						}
			move_index = move_result["next_index"]
		if best_move == Vector2(-1, -1):
			print("for ai:")
			print_board(board)
			push_error("WARNING: No valid moves found for AI!")
			
			
		
		return {
			"eval": maxEval,
			"move": best_move,
			"block1": best_block1,
			"block2": best_block2
		}
		
	else:  # Player's turn (minimizing)
		var minEval: int = 9223372036854775800
		var best_move: Vector2 = Vector2(-1, -1)
		var best_block1: Vector2 = Vector2(-1, -1)
		var best_block2: Vector2 = Vector2(-1, -1)
		
		var move_index: int = 0
		var max_index: int = 512
		
		while move_index < max_index:
			var move_result = generate_moves(board, player_pos, ai_pos, move_index)
			
			if GameData.DEBUG:
				var move_dir_idx: int = (move_index / 64) % 8 
				var block1_idx: int = (move_index / 8) % 8
				var block2_idx: int = move_index % 8 
				print(depth, " depth, checking position in PLAYER: ", move_dir_idx, block1_idx, block2_idx)
			
			if move_result["completed"] == 3:
				var evalResult = minimax(
					move_result["board"], 
					ai_pos, 
					move_result["move"], 
					depth - 1, 
					alpha, 
					beta, 
					true
				)
				#print("eval is ", evalResult["eval"], " minEval is: ", minEval)
				if evalResult["eval"] < minEval:
					#print(evalResult["eval"], " is smaller than ", minEval)
					minEval = evalResult["eval"]
					best_move = move_result["move"]
					best_block1 = move_result["block1"]
					best_block2 = move_result["block2"]
				
				# Alpha-Beta pruning
				if GameData.PRUNING:
					beta = min(beta, evalResult["eval"])
					if beta <= alpha: # and best_move != Vector2(-1, -1):
						break
			elif move_result["completed"] > 0:
				var victory : int = check_victory(ai_pos, move_result["move"], move_result["board"], maximizing_player)
				if victory == 2:
					if move_result["completed"] == 2:
						return {
							"eval" : 100000,
							"move" : move_result["move"],
							"block1" : move_result["block1"],
							"block2": Vector2(-1, -1)
						}
					elif move_result["completed"] == 1:
						return {
							"eval" : 100000,
							"move" : move_result["move"],
							"block1" : Vector2(-1, -1),
							"block2": Vector2(-1, -1)
						}
				elif victory == 1:
					if move_result["completed"] == 2:
						return {
							"eval" : -100000,
							"move" : move_result["move"],
							"block1" : move_result["block1"],
							"block2": Vector2(-1, -1)
						}
					elif move_result["completed"] == 1:
						return {
							"eval" : -100000,
							"move" : move_result["move"],
							"block1" : Vector2(-1, -1),
							"block2": Vector2(-1, -1)
						}
			move_index = move_result["next_index"]
		
		if best_move == Vector2(-1, -1):
			print("for player:")
			print_board(board)
			push_error("WARNING: No valid moves found for PLAYER!")
		
		return {
			"eval": minEval,
			"move": best_move,
			"block1": best_block1,
			"block2": best_block2
		}


# current player is 1 for player 2 for ai
func calculate_minimax_points(ai_pos: Vector2, player_pos: Vector2, board: Array, maximizing_player: bool) -> int:
	# returns the difference between self position (max_pos) and player position (min_pos)
	# Calculated by the amount of free blocks around each player.
	if check_victory(ai_pos, player_pos, board, maximizing_player) == 1:
		if GameData.DEBUG:
			print("Victory for Player detected in eval")
		return -100000
	elif check_victory(ai_pos, player_pos, board, maximizing_player) == 2:
		if GameData.DEBUG:
			print("Victory for AI detected in eval")
		return 100000
	
	var board_copy = board.duplicate(true)
	var self_mobility: int = calculate_position(ai_pos.x, ai_pos.y, board_copy)
	var opponent_mobility: int = calculate_position(player_pos.x, player_pos.y, board_copy)
	var points: int = self_mobility - opponent_mobility
	
	if self_mobility < 3:
		points -= 10
	
	return points


func toggle_buttons(parent: Node, is_turn: bool):
	# Toggle each button
	for child in parent.get_children():
		if child is Button:
			child.disabled = not is_turn


# Maybe make this into an update game func
func change_turn() -> void:
	print_board(Board)
	if Turn == "Player Turn":
		toggle_buttons(Board_Maker, true)
		
		if Turn_Type == "Move":
			Turn_Type = "Block1"
			Board_Maker.turn_label.text = "Your turn to 1st Block"
		elif Turn_Type == "Block1":
			Turn_Type = "Block2"
			Board_Maker.turn_label.text = "Your turn to 2nd Block"
		else:
			Turn_Number += 1
			Turn = "AI Turn"
			Board_Maker.turn_label.text = "AI is playing..."
			await get_tree().create_timer(0.1).timeout
			toggle_buttons(Board_Maker, false)
			ai_play()
	else:
		Turn_Number += 1
		Turn = "Player Turn"
		Turn_Type = "Move"
		Board_Maker.turn_label.text = "Your turn to Move"
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
# current_player 1 for Player, 2 for AI
# Returns: 0 for no victory, 1 for Player victory, 2 for AI victory
func check_victory(ai_pos: Vector2, player_pos: Vector2, board: Array, maximizing_player: bool) -> int:
	var board_copy: Array = board.duplicate(true)
	var player_mobility: int = calculate_position(player_pos.x, player_pos.y, board_copy)
	var ai_mobility: int = calculate_position(ai_pos.x, ai_pos.y, board_copy)
   
   # First check if the opponent of current player is trapped
	if not maximizing_player:  # Player's turn
	# Check if AI (opponent) is trapped
		if ai_mobility == 0:
			return 1  # Player wins
	else:  # AI's turn
	# Check if Player (opponent) is trapped
		if player_mobility == 0:
			return 2  # AI wins
   
   # Then check if current player trapped themselves
	if not maximizing_player and player_mobility == 0:
		return 2  # AI wins because Player trapped themselves
	elif maximizing_player and ai_mobility == 0:
		return 1  # Player wins because AI trapped itself
   
	return 0  # No victory yet


func victory():
	toggle_buttons(Board_Maker, false)
	# Make victory pop up visible
	Board_Maker.turn_label.text = "YOU WON"


func defeat():
	toggle_buttons(Board_Maker, false)
	# Make defeat pop up visible
	Board_Maker.turn_label.text = "YOU LOST"

func ai_play():
	# Get best move using minimax
	var result = minimax(Board, AI_Pos, Player_Pos, GameData.MINIMAX_DEPTH, -INF, INF, true)
	var best_move = result["move"]
	var best_block1 = result["block1"]
	var best_block2 = result["block2"]
	
	# Convert positions to strings for node lookup
	var ai_pos_string = vector2_to_string(AI_Pos)
	var best_move_string = vector2_to_string(best_move)
	
	# Move AI piece
	move_icon(Board_Maker.get_node(ai_pos_string), Board_Maker.get_node(best_move_string), best_move)
	move_AI(best_move)
	
	match check_victory(AI_Pos, Player_Pos, Board, true):
		1:
			victory()
		2: 
			defeat()
	
	
	# Place first block
	if best_block1 != Vector2(-1, -1):
		var block1_string = vector2_to_string(best_block1)
		place_block(Board_Maker.get_node(block1_string), best_block1)
	
	# Check for victory after blocks
	match check_victory(AI_Pos, Player_Pos, Board, true):
		1:
			victory()
		2: 
			defeat()
	
	# Place second block
	if best_block2 != Vector2(-1, -1):
		var block2_string = vector2_to_string(best_block2)
		place_block(Board_Maker.get_node(block2_string), best_block2)
	
	# Check for victory after blocks
	match check_victory(AI_Pos, Player_Pos, Board, true):
		1:
			victory()
		2: 
			defeat()
		0:
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
		if check_move(Player_Pos, Signal_Pos, Board):
			
			# Move player on Board
			move_player(Signal_Pos)
			# Move button icons
			move_icon(Board_Maker.get_node(player_pos_string), Board_Maker.get_node(new_pos_string), Signal_Pos)
			
			# Check if opponent has any moves after
			match check_victory(AI_Pos, Player_Pos, Board, false):
				1:
					victory()
				2: 
					defeat()
				0:
					change_turn()
	else:
		if Turn_Type == "Block1":
			if check_block(Signal_Pos, Board):
				place_block(Board_Maker.get_node(new_pos_string), Signal_Pos)
				
				# Check if opponent has any moves after
				match check_victory(AI_Pos, Player_Pos, Board, false):
					1:
						victory()
					2: 
						defeat()
					0:
						change_turn()
		elif Turn_Type == "Block2":
			if check_block(Signal_Pos, Board):
				place_block(Board_Maker.get_node(new_pos_string), Signal_Pos)
				
				# Check if opponent has any moves after
				match check_victory(AI_Pos, Player_Pos, Board, false):
					1:
						victory()
					2: 
						defeat()
					0:
						change_turn()


func _on_board_maker_board_ready() -> void:
	Board_Maker = self.get_child(0)
	print("BoardMaker is ready!")


#endregion

#region TEST_FUNCTIONS


func print_board(board: Array = Board) -> void:
	#for row in board:
		#print (row)
	for row in board:
		var line = ""
		for i in row:
			if i == 1:
				line += "1"
			elif i == 2:
				line += "2"
			elif i == -1:
				line += "0"
			else:
				line += "_"
		print(line)



func test_calculate_position() -> void:
	var oldBoard = [
		[0, 1, 0, 0],
		[0, 0, 2, 0],
		[0, 0, 0, 0],
		[0, 0, 0, 0]
	]

	var result = calculate_position(0, 1, oldBoard)
	print("Test Case 1 - Expected: 5, Got: ", result)  # (1,1) has two adjacent zeroes

	result = calculate_position(1,2, oldBoard)
	print("Test Case 2 - Expected: 2, Got: ", result)  # (0,0) has one adjacent zero

	result = calculate_position(2, 2, oldBoard)
	print("Test Case 3 - Expected: 6, Got: ", result)  # (2,2) has three adjacent zeroes

	result = calculate_position(3, 3, oldBoard)
	print("Test Case 4 - Expected: -1, Got: ", result) # (3,3) only counts itself and no adjacent zeroes

	result = calculate_position(-1, -1, oldBoard)
	print("Test Case 5 - Expected: -1, Got: ", result) # Out of bounds case
	
func test_calculate_position2():
	var test_board = [
		[0, 1, 0, 0, 0, 0, 0, 0],
		[0, 0, 2, -1, 0, 2, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, -1, 0, 1, 2, 0, -1, 0],
		[0, 0, 0, 2, 1, 0, 0, 0],
		[0, 2, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, -1, 0, 1, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0]
	]

	# Test case 1: Corner position (0,0)
	print("Test Case 1 - Corner (0,0): Expected: 2, Got:", calculate_position(0, 1, test_board))

	# Test case 2: Edge position (0,3)
	print("Test Case 2 - Edge (0,3): Expected: 4, Got:", calculate_position(1, 2, test_board))

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

func test_block_positions_equality(block1_pos: Vector2, block2_pos: Vector2) -> void:
	if block1_pos == block2_pos:
		print("Test Passed: block1_pos ", block1_pos, " is equal to block2_pos ", block2_pos)
	else:
		print("Test Failed: block1_pos ", block1_pos, " is NOT equal to block2_pos ", block2_pos)



func test_place_blocks_loop():
	var test_board = [
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 3, 3, 3, 0, 0],
		[0, 0, 3, 1, 3, 0, 0],
		[0, 0, 3, 3, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0]
	]
	
	var opponent_pos = Vector2(3, 3)
	var board_size: int = 7
	var blocks_placed: int = 0
	var radius: int = 1

	while blocks_placed < 2 and radius <= 8:
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				var block_pos = Vector2(opponent_pos.x + x, opponent_pos.y + y)
				
				#Check Board bounds - This check is essential 
				if block_pos.x < 0 or block_pos.x >= board_size or block_pos.y < 0 or block_pos.y >= board_size:
					continue #Skip and move to the next step
					
				# Check if it's empty and place 2 only
				if test_board[int(block_pos.x)][int(block_pos.y)] == 0:
					test_board[int(block_pos.x)][int(block_pos.y)] = 2
					print("Placed 2 at:", block_pos)  # Print for demonstration
					blocks_placed += 1
					if blocks_placed == 2:
						break  #Placing two blocks
			if blocks_placed == 2:
				break  #Placed two blocks
		if blocks_placed < 2:  #If positions filled then increase radius
			radius += 1

	#Print final board to see the layout.
	for row in test_board:
		print(row)


#endregion
