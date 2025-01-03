extends FlowContainer

@export var Board_Size_X = 8
@export var Board_Size_Y = 8

@export var Tile_Size_X: int = 50
@export var Tile_Size_Y: int = 50


signal board_ready
signal send_location


func _ready():
	
	# Load icons
	var player_1_icon_raw = preload("res://assets/icon.svg")
	var player_2_icon_raw = preload("res://assets/icon2.svg")
	var block_icon_raw = preload("res://assets/block.svg")
	
	# Set up the board - make button children
	for y in Board_Size_Y:
		self.size.y += Tile_Size_Y + 5
		self.size.x += Tile_Size_X + 5
		
		for x in Board_Size_X:
			var temp = Button.new()
			temp.set_custom_minimum_size(Vector2(Tile_Size_X, Tile_Size_Y))
			# Lambda func that sends button location signal to the Game.
			# Dont use lambda func if possible in the future.
			temp.connect("pressed", func():
				emit_signal("send_location", temp.name, y, x))
			
			#temp.set_button_icon(sprite)
			#temp.icon = preload("res://assets/icon.png")
			
			temp.set_name(str(y) + "-" + str(x))
			# Buttons are disabled by default until it is player's turn.
			temp.disabled = true
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

	# Make an invisible button to load and store Block Icon's image.
	# Can be later used to swap or copy icons from there.
	var secret_button = Button.new()
	secret_button.set_name("block")
	secret_button.visible = false
	secret_button.disabled = true
	add_child(secret_button)

	# Resize block icon for the invisible button.
	var image3 = block_icon_raw.get_image()
	image3.resize(Tile_Size_X-10, Tile_Size_Y-10, Image.INTERPOLATE_LANCZOS)
	var block_icon = ImageTexture.create_from_image(image3)

	get_node("block").icon = block_icon


	# Give board_ready signal to Game
	self.connect("board_ready", Callable(self, "_on_board_ready"))
	emit_signal("board_ready")
