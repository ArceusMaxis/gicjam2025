extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 10.0
@export var mouse_sensitivity: float = 0.1

const GOOD_TIME: float = 20.0
const FLICKER_TIME: float = 8.0
const DYING_TIME: float = 2.0
const TOTAL_TIME: float = GOOD_TIME + FLICKER_TIME + DYING_TIME

enum MatchState { GOOD, FLICKERING, DYING, DEAD }
var current_state: MatchState = MatchState.GOOD
var match_timer: float = 0.0

@onready var camera: Camera3D = $Camera3D
@onready var timer: Timer = $Timer
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		timer.wait_time = TOTAL_TIME
		timer.timeout.connect(_on_match_timeout)
		timer.start()
		_update_match_state()

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
			print("good")
		MatchState.FLICKERING:
			anim.play("flicker")
			print("flicker")
		MatchState.DYING:
			anim.play("dying")
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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
