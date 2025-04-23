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


func _on_center_positions_check_button_toggled(toggled_on: bool) -> void:
	GameData.CENTER_POS = toggled_on


func _on_pruning_check_button_toggled(toggled_on: bool) -> void:
	GameData.PRUNING = toggled_on
	if not GameData.PRUNING and GameData.MINIMAX_DEPTH > 3:
		$VBoxContainer/WaitTimeLabel.visible = true
	else:
		$VBoxContainer/WaitTimeLabel.visible = false


func _on_minimax_depth_slider_value_changed(value: float) -> void:
	$VBoxContainer/VBoxContainer/MinimaxDepthLabel.text = "Minimax Depth: " + str(value)
	GameData.MINIMAX_DEPTH = value
	if not GameData.PRUNING and GameData.MINIMAX_DEPTH > 3:
		$VBoxContainer/WaitTimeLabel.visible = true
	else:
		$VBoxContainer/WaitTimeLabel.visible = false
