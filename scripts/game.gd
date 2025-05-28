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
var Player_Pos: Vector2i
# Gives AI Position, updated once every turn.
var AI_Pos: Vector2i
# Gives Player Click Position, updated thrice every turn.
var Signal_Pos: Vector2i = Vector2i(-1, -1)
# Variable that changes every time board is clicked.
var New_Button_Signal: bool = false
# BoardMaker Node - for accessing buttons
var Board_Maker : Node

var Late_Game : bool = false
var Turn_Number: int = 1

#Test variables
var Minimax_Called =  {
	"depth0": 0,
	"depth1": 0,
	"depth2": 0,
	"depth3": 0,
	"depth4": 0,
	"depth5": 0,
	"depth6": 0
}
var Pruning_Called = {
	"depth0": 0,
	"depth1": 0,
	"depth2": 0,
	"depth3": 0,
	"depth4": 0,
	"depth5": 0,
	"depth6": 0
}
var Branching_Factor: int = 0
var Pruned_Branches: int = 0

# Return type of generate_moves function.
class MoveResult:
	var completed: int = 0
	var next_index: int = 0
	# initing complex variables like arrays without init func
	# may set them as a reference!
	var board: Array
	var move: Vector2i = Vector2i(-1, -1)
	var block1: Vector2i = Vector2i(-1, -1)
	var block2: Vector2i = Vector2i(-1, -1)

# Return type of minimax function.
class MinimaxResult:
	var eval: int = 0
	var move: Vector2i = Vector2i(-1, -1)
	var block1: Vector2i = Vector2i(-1, -1)
	var block2: Vector2i = Vector2i(-1, -1)


# Default func called when node enters the scene. (on load)
func _ready() -> void:
	#test_place_blocks_loop()
	
	# Wait until buttons are ready. LOADING TIME
	await get_tree().create_timer(0.1).timeout
	while Board_Maker == null:
		continue
	
	# Connect navigation buttons.
	$BoardMaker.connect("return_to_menu", Callable(self, "_change_to_menu_scene"))
	$BoardMaker.connect("reload_game", Callable(self, "_restart_current_game"))
	
	print("minimax depth is ", GameData.MINIMAX_DEPTH)
	
	initiate_board()
	
	# LOAD TIME - AI move calculations freeze board render otherwise.
	await get_tree().create_timer(0.1).timeout
	
	determine_first_turn()
	
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
		Player_Pos = Vector2i(4, 3)
		AI_Pos = Vector2i(3, 4)
		Board[4][3] = 1 # Player
		Board[3][4] = 2 # AI
	else:
		Player_Pos = Vector2i(7, 3)
		AI_Pos = Vector2i(0, 4)
		Board[7][3] = 1 # Player
		Board[0][4] = 2 # AI


func determine_first_turn() -> void:
	var first_turn : int = randi() % 2
	if first_turn == 1:
		Board_Maker.turn_label.text = "Your Turn"
		Turn = "Player Turn"
		if GameData.DEBUG:
			print ("First Turn is ", Turn)
		toggle_buttons(Board_Maker, true)
	elif first_turn == 0:
		Board_Maker.turn_label.text = "AI is thinking..."
		await get_tree().create_timer(0.1).timeout
		Turn = "AI Turn"
		if GameData.DEBUG:
			print ("First Turn is ", Turn)
		toggle_buttons(Board_Maker, false)
		ai_play()


func vector2i_to_string(vec: Vector2i) -> String:
	return str(vec.x) + "-" + str(vec.y)


# Not using the last parameter. Find out what that was.
func move_icon(old_pos: Node, new_pos: Node, on_board_new_pos: Vector2i):
	# Handle Button icons for positions
	#print("old_pos.name: ", old_pos.name)
	#print("new_pos.name: ", new_pos.name)
	var old_pos_icon = old_pos.get_button_icon()
	var new_pos_icon = new_pos.get_button_icon()
	old_pos.set_button_icon(new_pos_icon)
	new_pos.set_button_icon(old_pos_icon)


func move_player(new_pos: Vector2i):
	# Move on Board
	Board[Player_Pos.x][Player_Pos.y] = 0
	Board[new_pos.x][new_pos.y] = 1
	Player_Pos = new_pos


func move_AI(new_pos: Vector2i):
	# Move on Board
	Board[AI_Pos.x][AI_Pos.y] = 0
	Board[new_pos.x][new_pos.y] = 2
	AI_Pos = new_pos


func place_block(pos: Node, on_board_pos: Vector2i):
	# Should be similar to move_player.
	# Set Icon
	var block_icon = Board_Maker.get_node("block").get_button_icon()
	pos.set_button_icon(block_icon)
	Board[on_board_pos.x][on_board_pos.y] = -1


func check_move(old_pos: Vector2i, new_pos: Vector2i, board: Array) -> bool:
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


func check_block(pos: Vector2i, board: Array) -> bool:
	# Check if inside board
	
	if not (index_in_bounds(pos.x, 8) and index_in_bounds(pos.y, 8)):
		return false
	# Check if position is empty
	if board[pos.x][pos.y] == 0:
		return true
	else:
		return false


# Generates A SINGLE move with given index.
func generate_moves(board: Array, self_pos: Vector2i, opponent_pos: Vector2i, move_index: int = 0) -> MoveResult:
	# Directions for movement:
	var directions: Array = [
		Vector2i(-1, 1),   # bottom left
		Vector2i(0, 1),    # bot
		Vector2i(1, 1),    # botright
		Vector2i(1, 0),    # right
		Vector2i(1, -1),   # topright
		Vector2i(0, -1),   # top
		Vector2i(-1, -1),  # topleft
		Vector2i(-1, 0)    # left
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
	var direction: Vector2i = directions[move_dir_idx]
	var new_pos = Vector2i(x + direction.x, y + direction.y)
	
	var result : MoveResult = MoveResult.new()
	
	# If this move is invalid, skip to next move
	if not check_move(self_pos, new_pos, board):
		result.completed = 0
		result.next_index = move_index + 64
		return result
	
	# Create board with move applied
	var moved_board: Array = board.duplicate(true)
	moved_board[x][y] = 0
	moved_board[new_pos.x][new_pos.y] = player
	
	# Calculate first block position
	var block1_dir: Vector2i = directions[block1_idx]
	var block1_pos: Vector2i = Vector2i(opponent_pos.x + block1_dir.x, opponent_pos.y + block1_dir.y)
	
	# If first block position is invalid, try next block position
	if not check_block(block1_pos, moved_board):
		result.completed = 1
		result.next_index = move_index + 8
		result.board = moved_board
		result.move = new_pos
		return result
	# fixed from "next_index": move_index + 8 - (move_index % 8)
	
	# Apply first block
	moved_board[block1_pos.x][block1_pos.y] = -1
	
	# Calculate second block position
	var block2_dir = directions[block2_idx]
	var block2_pos = Vector2i(opponent_pos.x + block2_dir.x, opponent_pos.y + block2_dir.y)
	
	# If second block position is invalid, try next second block
	if (not check_block(block2_pos, moved_board)) or block1_pos == block2_pos:
		result.completed = 2
		result.next_index = move_index + 1
		result.board = moved_board
		result.move = new_pos
		result.block1 = block1_pos
		return result
		# MIGHT BE +64 ########################################
	# fixed from "next_index": move_index + 64
	
	# Apply second block
	moved_board[block2_pos.x][block2_pos.y] = -1
	
	result.completed = 3
	result.next_index = move_index + 1
	result.board = moved_board
	result.move = new_pos
	result.block1 = block1_pos
	result.block2 = block2_pos
	return result
	# Return move data with next index


# alpha is the best score the maximizer can guarantee so far.
# beta is the best score the minimizer can guarantee so far
func minimax(board: Array, ai_pos: Vector2i, player_pos: Vector2i, depth: int, alpha: int, beta: int, maximizing_player: bool) -> MinimaxResult:
	var result: MinimaxResult = MinimaxResult.new()
	match depth:
		0:
			Minimax_Called["depth0"] += 1
		1:
			Minimax_Called["depth1"] += 1
		2:
			Minimax_Called["depth2"] += 1
		3:
			Minimax_Called["depth3"] += 1
		4:
			Minimax_Called["depth4"] += 1
		5:
			Minimax_Called["depth5"] += 1
		6:
			Minimax_Called["depth6"] += 1
	# Terminal conditions: depth reached or victory detected
	if depth == 0 or check_victory(ai_pos, player_pos, board, maximizing_player) != 0:
		var eval: int = calculate_minimax_points(ai_pos, player_pos, board, maximizing_player, depth)
		result.eval = eval
		return result
	
	if maximizing_player:  # AI's turn (maximizing)
		var maxEval: int = -9223372036854775800
		var best_move: Vector2i = Vector2i(-1, -1)
		var best_block1: Vector2i = Vector2i(-1, -1)
		var best_block2: Vector2i = Vector2i(-1, -1)
		
		# Start generating moves incrementally
		var move_index: int = 0
		var max_index: int = 512
		
		while move_index < max_index:
			var move_result : MoveResult = MoveResult.new()
			move_result = generate_moves(board, ai_pos, player_pos, move_index)
			
			if GameData.DEBUG:
				var move_dir_idx: int = (move_index / 64) % 8 
				var block1_idx: int = (move_index / 8) % 8
				var block2_idx: int = move_index % 8 
				print(depth, " depth, checking position in AI: ", move_dir_idx, block1_idx, block2_idx)
				
			
			if move_result.completed == 3:
				var eval_result : MinimaxResult = MinimaxResult.new()
				eval_result = minimax(
					move_result.board, 
					move_result.move, 
					player_pos, 
					depth - 1, 
					alpha, 
					beta, 
					false
				)

				if eval_result.eval > maxEval:
					maxEval = eval_result.eval
					best_move = move_result.move
					best_block1 = move_result.block1
					best_block2 = move_result.block2
					
				# Alpha-Beta pruning
				if GameData.PRUNING:
					alpha = max(alpha, eval_result.eval)
					if beta <= alpha:
						match depth:
							0:
								Pruning_Called["depth0"] += 1
							1:
								Pruning_Called["depth1"] += 1
							2:
								Pruning_Called["depth2"] += 1
							3:
								Pruning_Called["depth3"] += 1
							4:
								Pruning_Called["depth4"] += 1
							5:
								Pruning_Called["depth5"] += 1
							6:
								Pruning_Called["depth6"] += 1
						if GameData.DEBUG:
							print("Pruning in AI with eval ", eval_result.eval, " beta is ", beta, " alpha is ", alpha)
						break
			elif move_result.completed > 0:
				# May call minimax depth 0 instead:
				var win : int = check_victory(move_result.move, player_pos, move_result.board, maximizing_player)
				if win == 2:
					result.eval = (100000 + (10*depth))
					result.move = move_result.move
					if move_result.completed == 2:
						result.block1 = move_result.block1
						return result
			move_index = move_result.next_index
			
		if GameData.DEBUG:
			if best_move == Vector2i(-1, -1):
				print("for ai:")
				print_board(board)
				push_error("WARNING: No valid moves found for AI!")
			
		result.eval = maxEval
		result.move = best_move
		result.block1 = best_block1
		result.block2 = best_block2
		return result
		
	else:  # Player's turn (minimizing)
		var minEval: int = 9223372036854775800
		var best_move: Vector2i = Vector2i(-1, -1)
		var best_block1: Vector2i = Vector2i(-1, -1)
		var best_block2: Vector2i = Vector2i(-1, -1)
		
		var move_index: int = 0
		var max_index: int = 512
		
		while move_index < max_index:
			var move_result : MoveResult = MoveResult.new()
			move_result = generate_moves(board, player_pos, ai_pos, move_index)
			
			if GameData.DEBUG:
				var move_dir_idx: int = (move_index / 64) % 8 
				var block1_idx: int = (move_index / 8) % 8
				var block2_idx: int = move_index % 8 
				print(depth, " depth, checking position in PLAYER: ", move_dir_idx, block1_idx, block2_idx)
			
			if move_result.completed == 3:
				var eval_result: MinimaxResult = MinimaxResult.new()
				eval_result = minimax(
					move_result.board, 
					ai_pos, 
					move_result.move, 
					depth - 1, 
					alpha, 
					beta, 
					true
				)
				
				if eval_result.eval < minEval:
					minEval = eval_result.eval
					best_move = move_result.move
					best_block1 = move_result.block1
					best_block2 = move_result.block2
				
				# Alpha-Beta pruning
				if GameData.PRUNING:
					beta = min(beta, eval_result.eval)
					if beta <= alpha:
						match depth:
							0:
								Pruning_Called["depth0"] += 1
							1:
								Pruning_Called["depth1"] += 1
							2:
								Pruning_Called["depth2"] += 1
							3:
								Pruning_Called["depth3"] += 1
							4:
								Pruning_Called["depth4"] += 1
							5:
								Pruning_Called["depth5"] += 1
							6:
								Pruning_Called["depth6"] += 1
						if GameData.DEBUG:
							print("Pruning in Player with eval ", eval_result.eval, " beta is ", beta, " alpha is ", alpha)
						break
			elif move_result.completed > 0:
				var win : int = check_victory(ai_pos, move_result.move, move_result.board, maximizing_player)
				if win == 1:
					result.eval = (-100000 - (10*depth))
					result.move = move_result.move
					if move_result.completed == 2:
						result.block1 = move_result.block1
					return result
			move_index = move_result.next_index
			
		if GameData.DEBUG:
			if best_move == Vector2i(-1, -1):
				print("for player:")
				print_board(board)
				push_error("WARNING: No valid moves found for PLAYER!")
		
		result.eval = minEval
		result.move = best_move
		result.block1 = best_block1
		result.block2 = best_block2
		return result


# 1 for player, 2 for ai
func calculate_minimax_points(ai_pos: Vector2i, player_pos: Vector2i, board: Array, maximizing_player: bool, depth: int) -> int:
	# returns the difference between self position (max_pos) and player position (min_pos)
	# Calculated by the amount of free blocks around each player.
	if check_victory(ai_pos, player_pos, board, maximizing_player) == 1:
		if GameData.DEBUG:
			print("Victory for Player detected in eval")
		return (-100000 - (10*depth))
	elif check_victory(ai_pos, player_pos, board, maximizing_player) == 2:
		if GameData.DEBUG:
			print("Victory for AI detected in eval")
		return (100000 + (10*depth))
	
	
	var self_mobility: int = calculate_position(ai_pos.x, ai_pos.y, board)
	var opponent_mobility: int = calculate_position(player_pos.x, player_pos.y, board)
	var points: int = self_mobility - opponent_mobility
	
	#if self_mobility <= 3:
		#points -= 3
	
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
			Turn_Type = "Block1"
			Board_Maker.turn_label.text = "Your turn to 1st Block"
		elif Turn_Type == "Block1":
			Turn_Type = "Block2"
			Board_Maker.turn_label.text = "Your turn to 2nd Block"
		else:
			Turn_Number += 1
			Turn = "AI Turn"
			Board_Maker.turn_label.text = "AI is thinking..."
			toggle_buttons(Board_Maker, false)
			await get_tree().create_timer(0.1).timeout
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
			if index_in_bounds(x, 8) and index_in_bounds(y, 8) and board[x][y] == 0:
				points += 1
	
	return points

# Helper function to check if an index is within bounds
func index_in_bounds(index: int, size: int) -> bool:
	return index >= 0 and index < size


# This func may just call Victory func and return nothing at all.
# current_player 1 for Player, 2 for AI
# Returns: 0 for no victory, 1 for Player victory, 2 for AI victory
func check_victory(ai_pos: Vector2i, player_pos: Vector2i, board: Array, maximizing_player: bool) -> int:
	var player_mobility: int = calculate_position(player_pos.x, player_pos.y, board)
	var ai_mobility: int = calculate_position(ai_pos.x, ai_pos.y, board)
   
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


func iterative_depth():
	
	if Late_Game:
		return
	GameData.MINIMAX_DEPTH = 3 # Max depth with a feasible wait time
	
	var player_mobility: int = calculate_position(Player_Pos.x, Player_Pos.y, Board)
	var ai_mobility: int = calculate_position(AI_Pos.x, AI_Pos.y, Board)
	
	if Turn_Number < 3: # Early game
		GameData.MINIMAX_DEPTH = 2
	if ai_mobility <= 3 or player_mobility <= 3: # Late game
		Late_Game = true
		GameData.MINIMAX_DEPTH = 5
	#print ("iterative depth is ", GameData.MINIMAX_DEPTH)
	


func ai_play():
	# Changes minimax depth based on board state and turn number
	if GameData.ITERATIVE_DEPTH:
		iterative_depth()
		
	# START TIMER
	var timer = Timer.new()
	var start_time = Time.get_ticks_msec()
	# Start the timer
	add_child(timer)
	timer.start()

	# Get best move using minimax
	var result : MinimaxResult = MinimaxResult.new()
	result = minimax(Board, AI_Pos, Player_Pos, GameData.MINIMAX_DEPTH, -9223372036854775800, 9223372036854775800, true)
	print("Minimax Called is ",Minimax_Called)
	print("Pruning Called is ",Pruning_Called)
	Minimax_Called["depth0"] = 0
	Minimax_Called["depth1"] = 0
	Minimax_Called["depth2"] = 0
	Minimax_Called["depth3"] = 0
	Minimax_Called["depth4"] = 0
	Minimax_Called["depth5"] = 0
	Minimax_Called["depth6"] = 0
	
	Pruning_Called["depth0"] = 0
	Pruning_Called["depth1"] = 0
	Pruning_Called["depth2"] = 0
	Pruning_Called["depth3"] = 0
	Pruning_Called["depth4"] = 0
	Pruning_Called["depth5"] = 0
	Pruning_Called["depth6"] = 0
	
	# GET ELAPSED TIME:
	timer.stop()
	var time_elapsed = (Time.get_ticks_msec() - start_time) / 1000.0  # in seconds
	print("minimax took: ", time_elapsed, " seconds with depth ", GameData.MINIMAX_DEPTH)
	timer.queue_free()  # Clean up the timer node
	
	var best_move = result.move
	var best_block1 = result.block1
	var best_block2 = result.block2
	
	# Convert positions to strings for node lookup
	var ai_pos_string = vector2i_to_string(AI_Pos)
	var best_move_string = vector2i_to_string(best_move)
	
	# Move AI piece
	move_icon(Board_Maker.get_node(ai_pos_string), Board_Maker.get_node(best_move_string), best_move)
	move_AI(best_move)
	
	
	match check_victory(AI_Pos, Player_Pos, Board, true):
		1:
			victory()
		2: 
			defeat()
	
	
	# Place first block
	if best_block1 != Vector2i(-1, -1):
		var block1_string = vector2i_to_string(best_block1)
		place_block(Board_Maker.get_node(block1_string), best_block1)
	
	# Check for victory after blocks
	match check_victory(AI_Pos, Player_Pos, Board, true):
		1:
			victory()
		2: 
			defeat()
	
	# Place second block
	if best_block2 != Vector2i(-1, -1):
		var block2_string = vector2i_to_string(best_block2)
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
	Signal_Pos = Vector2i(y, x)
	#New_Button_Signal = true
	if GameData.DEBUG:
		print("Player Clicked: ", name)
	#print("signal pos: ", Signal_Pos)
	# Stringify the vectors so they can reach buttons.
	var player_pos_string = vector2i_to_string(Player_Pos)
	var new_pos_string = vector2i_to_string(Signal_Pos)
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

func _change_to_menu_scene():
	# Set global variables to default
	GameData.MINIMAX_DEPTH = 3
	GameData.PRUNING = false
	GameData.CENTER_POS = false
	GameData.DEBUG = false
	GameData.ITERATIVE_DEPTH = false
	# Set scene
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func _restart_current_game():
	get_tree().reload_current_scene()

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

func test_block_positions_equality(block1_pos: Vector2i, block2_pos: Vector2i) -> void:
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
	
	var opponent_pos = Vector2i(3, 3)
	var board_size: int = 7
	var blocks_placed: int = 0
	var radius: int = 1

	while blocks_placed < 2 and radius <= 8:
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				var block_pos = Vector2i(opponent_pos.x + x, opponent_pos.y + y)
				
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
