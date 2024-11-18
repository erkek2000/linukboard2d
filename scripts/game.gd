extends Control

var board: Array = []



func print_board():
	for row in board:
		print(row)

func _ready() -> void:
	
	# INITIATE BOARD ARRAY
	#
	# 0 - Empty Squares
	# 1 - Player 1
	# 2 - Player 2
	# -1 - Blocked Squares
	#
	for row in range(8):
		var new_row = []  # Make an empty new row before filling it.
		for col in range(8):
			new_row.append(0) # 0 for empty squares.
		board.append(new_row)  # Add the row to the board
	board[7][3] = 1
	board[0][4] = 2
	
	#var b = get_node("7-3")
	print_board()
	#b.set_button_icon()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#region SIGNALS
# Button Pressed signal form BoardMaker.
func _on_board_maker_send_location(name, turn) -> void:
	print(name)
	pass # Replace with function body.
#endregion
