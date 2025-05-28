extends FlowContainer
@export var Board_Size_X = 8
@export var Board_Size_Y = 8
@export var Tile_Size_X: int = 50
@export var Tile_Size_Y: int = 50
signal board_ready
signal send_location
signal return_to_menu
signal reload_game

# Reference to our turn label
var turn_label: Label

func _ready():
	
	# Load icons
	var player_1_icon_raw = preload("res://assets/icon.svg")
	var player_2_icon_raw = preload("res://assets/icon2.svg")
	var block_icon_raw = preload("res://assets/greenBlock.svg")
	
	# Set up the board - make button children
	for y in Board_Size_Y:
		self.size.y += Tile_Size_Y + 5
		self.size.x += Tile_Size_X + 5
		
		for x in Board_Size_X:
			var temp = Button.new()
			if GameData.DEBUG:
				temp.text = str(y) + "-" + str(x)
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
	
	if GameData.CENTER_POS:
		get_node("4-3").icon = player_1_icon
		get_node("3-4").icon = player_2_icon
	else:
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
	
	# Create turn label after all buttons
	turn_label = Label.new()
	turn_label.set_name("TurnLabel")
	turn_label.text = "Loading"
	turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_label.custom_minimum_size = Vector2(Board_Size_X * (Tile_Size_X + 5), 30)
	turn_label.add_theme_font_size_override("font_size", 18)
	add_child(turn_label)
	
	# Create a horizontal container for navigation buttons
	var button_container = HBoxContainer.new()
	button_container.set_name("NavigationButtons")
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.custom_minimum_size = Vector2(Board_Size_X * (Tile_Size_X + 5), 40)
	add_child(button_container)
	
	# Create Return to Menu button
	var menu_button = Button.new()
	menu_button.set_name("ReturnToMenuButton")
	menu_button.text = "Return to Menu"
	menu_button.custom_minimum_size = Vector2(150, 30)
	menu_button.connect("pressed", Callable(self, "_on_menu_button_pressed"))
	button_container.add_child(menu_button)
	
	# Add some spacing between buttons
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	button_container.add_child(spacer)
	
	# Create Reload Game button
	var reload_button = Button.new()
	reload_button.set_name("ReloadGameButton")
	reload_button.text = "Reload Game"
	reload_button.custom_minimum_size = Vector2(150, 30)
	reload_button.connect("pressed", Callable(self, "_on_reload_button_pressed"))
	button_container.add_child(reload_button)
	
	# Give board_ready signal to Game
	self.connect("board_ready", Callable(self, "_on_board_ready"))
	emit_signal("board_ready")

# Function to update the turn label text
func update_turn_text(text: String) -> void:
	turn_label.text = text

# Function that handles the Return to Menu button press
func _on_menu_button_pressed() -> void:
	emit_signal("return_to_menu")

# Function that handles the Reload Game button press
func _on_reload_button_pressed() -> void:
	emit_signal("reload_game")
