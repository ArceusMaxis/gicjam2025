extends Control

@onready var play: Button = $VBoxContainer/Play
@onready var credits: Button = $VBoxContainer/Credits
@onready var gicj: Button = $VBoxContainer/GICJ
@onready var quit: Button = $VBoxContainer/Quit
const SEWERS = preload("res://scenes/sewers.tscn")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(SEWERS)

func _on_credits_pressed() -> void:
	OS.shell_open("https://chaak-007.itch.io")

func _on_gicj_pressed() -> void:
	OS.shell_open("https://itch.io/jam/godot-india-community-game-jam")

func _on_quit_pressed() -> void:
	get_tree().quit()
