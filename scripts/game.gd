extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Button Pressed signal form BoardMaker.
func _on_board_maker_send_location(name) -> void:
	print(name)
	pass # Replace with function body.