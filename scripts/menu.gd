extends Node

# Quit the game
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
# Navigate to Info scene
func _on_info_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/info.tscn")

# Navigate to Game scene
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
