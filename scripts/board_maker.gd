extends FlowContainer

@export var Board_Size_X = 8
@export var Board_Size_Y = 8

@export var Tile_Size_X: int = 50
@export var Tile_Size_Y: int = 50

var turn: String = "Player"

signal send_location

func _ready():
	# stop negative numbers from happening
	#if Board_Size_X < 0 or Board_Size_Y < 0:
	#	return
		
	# Set up the board
	for y in Board_Size_Y:
		self.size.y += Tile_Size_Y + 5
		self.size.x += Tile_Size_X + 5
		
		for x in Board_Size_X:
			var temp = Button.new()
			temp.set_custom_minimum_size(Vector2(Tile_Size_X, Tile_Size_Y))
			temp.connect("pressed", func():
				emit_signal("send_location", temp.name, turn))
		
			#temp.button_pressed
			temp.set_name(str(x) + "-" + str(y))
			add_child(temp)
		
