extends Control

@onready var banner: TextureRect = $Banner
@onready var play: Button = $VBoxContainer/Play
@onready var credits: Button = $VBoxContainer/Credits
@onready var gicj: Button = $VBoxContainer/GICJ
@onready var quit: Button = $VBoxContainer/Quit
@onready var label: Label = $Banner/Label

var vis : bool = false
var _timer = 0.0
var blink_speed = 0.3
const SEWERS = preload("res://scenes/sewers.tscn")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$VideoStreamPlayer.play()

func _on_play_pressed() -> void:
	banner.visible = true
	vis = true

func labelblink(delta):
	_timer += delta
	if _timer >= blink_speed:
		_timer = 0.0
		label.visible = !label.visible

func _on_credits_pressed() -> void:
	OS.shell_open("https://chaak-007.itch.io")

func _on_gicj_pressed() -> void:
	OS.shell_open("https://itch.io/jam/godot-india-community-game-jam")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _physics_process(delta: float) -> void:
	labelblink(delta)
	if vis:
		if Input.is_anything_pressed():
			get_tree().change_scene_to_packed(SEWERS)
