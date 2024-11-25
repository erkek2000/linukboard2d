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
	#b.set_button_icon()
	
func update_game():
	
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
	
func calculate_position():
	pass


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
