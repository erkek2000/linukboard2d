extends FlowContainer

@export var Board_Size_X = 8
@export var Board_Size_Y = 8

@export var Tile_Size_X: int = 50
@export var Tile_Size_Y: int = 50


var Turn: String = "Player Turn"

# Can be Move or Block
var Turn_Type: String = "Move"

signal send_location
	
func _ready():
	
	# Determine first turn
	var first_turn : int = randi() % 2
	if first_turn == 1:
		Turn = "Player Turn"
	elif first_turn == 0:
		Turn = "AI Turn"

	var player_1_icon_raw = preload("res://assets/icon.svg")
	var player_2_icon_raw = preload("res://assets/icon2.svg")
	
	# Set up the board
	for y in Board_Size_Y:
		self.size.y += Tile_Size_Y + 5
		self.size.x += Tile_Size_X + 5
		
		for x in Board_Size_X:
			var temp = Button.new()
			temp.set_custom_minimum_size(Vector2(Tile_Size_X, Tile_Size_Y))
			temp.connect("pressed", func():
				emit_signal("send_location", temp.name, Turn, Turn_Type, x, y))
				
			#temp.set_button_icon(sprite)
			#temp.icon = preload("res://assets/icon.png")
			
			temp.set_name(str(y) + "-" + str(x))
			add_child(temp)
			
	# Create a new image and texture for each button and player
	var image = player_1_icon_raw.get_image()
	image.resize(Tile_Size_X-10, Tile_Size_Y-10, Image.INTERPOLATE_LANCZOS)
	var player_1_icon = ImageTexture.create_from_image(image)
	
	var image2 = player_2_icon_raw.get_image()
	image2.resize(Tile_Size_X-10, Tile_Size_Y-10, Image.INTERPOLATE_LANCZOS)
	var player_2_icon = ImageTexture.create_from_image(image2)
	
	get_node("7-3").icon = player_1_icon
	get_node("0-4").icon = player_2_icon
		
