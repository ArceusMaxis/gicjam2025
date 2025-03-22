extends CharacterBody3D

@export var speed: float = 2.0
@export var acceleration: float = 10.0
@export var mouse_sensitivity: float = 0.1
@onready var match_label: Label = $Control/Label
@export var quip_array : Array[String]

const DYING = preload("res://audio/dying.wav")
const GOOD_CRACKLE = preload("res://audio/good_crackle.wav")
const GOOD_MATCH_START = preload("res://audio/good_match_start.wav")
const LOUD_CRACKLE = preload("res://audio/loud_crackle.wav")

const GOOD_TIME: float = 20.0
const FLICKER_TIME: float = 8.0
const DYING_TIME: float = 2.0
const TOTAL_TIME: float = GOOD_TIME + FLICKER_TIME + DYING_TIME

enum MatchState { GOOD, FLICKERING, DYING, DEAD }
var current_state: MatchState = MatchState.GOOD
var match_timer: float = 0.0

@onready var audiop: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var camera: Camera3D = $Camera3D
@onready var timer: Timer = $Timer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var quip: Label = $Control/quip
@onready var noiser_timer: Timer = $NoiserParent/NoiserTimer
@onready var noiser: AudioStreamPlayer3D = $NoiserParent/Noiser
@onready var noiser_parent: Marker3D = $NoiserParent
@onready var fsa: AudioStreamPlayer = $FSA

func _ready() -> void:
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	timer.wait_time = TOTAL_TIME
	timer.timeout.connect(_on_match_timeout)
	timer.start()
	noiser_timer.timeout.connect(noises)
	_update_match_state()
	await get_tree().create_timer(randi_range(10,15)).timeout
	quip_random()

func _process(delta: float) -> void:
	match_timer += delta
	var new_state: MatchState = current_state
	if match_timer <= GOOD_TIME:
		new_state = MatchState.GOOD
	elif match_timer <= GOOD_TIME + FLICKER_TIME:
		new_state = MatchState.FLICKERING
	elif match_timer <= TOTAL_TIME:
		new_state = MatchState.DYING
	else:
		new_state = MatchState.DEAD
	if new_state != current_state:
		current_state = new_state
		_update_match_state()

func _update_match_state() -> void:
	match current_state:
		MatchState.GOOD:
			anim.play("good")
			audiop.stream = GOOD_MATCH_START
			audiop.play()
			$Crackle.play()
			print("good")
		MatchState.FLICKERING:
			anim.play("flicker")
			audiop.stream = LOUD_CRACKLE
			audiop.play()
			print("flicker")
		MatchState.DYING:
			if Global.extra_matches > 0:
				Global.extra_matches -= 1
				match_timer = 0.0
				current_state = MatchState.GOOD
				anim.play("good")
				print("good")
			else:
				anim.play("dying")
				audiop.stream = DYING
				audiop.play()
				print("dying")
		MatchState.DEAD:
			anim.play("dead")
			await anim.animation_finished
			print("reloading")
			Global.reload_game()

func _on_match_timeout() -> void:
	current_state = MatchState.DEAD
	_update_match_state()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		var pitch = deg_to_rad(-event.relative.y * mouse_sensitivity)
		var current_rotation = camera.rotation.x
		camera.rotation.x = clamp(current_rotation + pitch, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	var input_dir := Vector3.ZERO
	input_dir.x = Input.get_axis("left", "right")
	input_dir.z = Input.get_axis("up", "down")
	
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.z)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
	
	velocity.y += -9.8 * delta
	move_and_slide()
	
	if velocity.length() != 0:
		if !fsa.playing:
			fsa.play()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Control/Pause.visible = true
		get_tree().paused = true

func new_match():
	match_label.visible = true
	await get_tree().create_timer(1.0).timeout
	match_label.visible = false

func _on_p_but_pressed() -> void:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Control/Pause.visible = false
		get_tree().paused = false

func _on_q_but_pressed() -> void:
	get_tree().quit()

func _on_qmm_but_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func quip_random():
	quip.text = quip_array.pick_random()
	quip.visible = true
	await get_tree().create_timer(2.0).timeout
	quip.visible = false
	await get_tree().create_timer(randi_range(10,15)).timeout
	quip_random()
	
func noises():
	noiser_parent.rotation_degrees.y = randi_range(0,360)
	noiser.play()
	noiser_timer.wait_time = randi_range(6,20)
	noiser_timer.start()
