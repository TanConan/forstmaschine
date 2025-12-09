extends CharacterBody3D

var gravity : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
var speed := 5.0
var jump_speed := 5.0
var mouse_sensitivity := 0.002
var gamepad_sensitivity := 0.02

@onready var cam := $Camera3D

@export var footstep_audio : AudioStreamPlayer3D
var footstep_time := 0.0
@export var footstep_velocity_multiplier : Curve
var prev_on_floor := true

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var gamepad_look_input = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if gamepad_look_input.length() >= 0.0:
		rotate_head(gamepad_look_input * gamepad_sensitivity)

func _physics_process(delta):
	velocity += gravity * delta
	var input = Input.get_vector("left", "right", "forward", "back", 0.25)
	var movement_dir = basis * Vector3(input.x, 0, input.y)
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed

	move_and_slide()
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		jump()
	elif is_on_floor() and not prev_on_floor: # Landing
		footstep_audio.play()
	handle_footstep(delta)
	prev_on_floor = is_on_floor()

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_head(Vector2(event.screen_relative.x * mouse_sensitivity, event.screen_relative.y * mouse_sensitivity))

func rotate_head(relative_input: Vector2):
	rotate_y(-relative_input.x)
	cam.rotate_x(-relative_input.y)
	cam.rotation.x = clampf(cam.rotation.x, -deg_to_rad(80), deg_to_rad(80))

func jump():
	velocity.y = jump_speed
	footstep_audio.play()

func handle_footstep(delta: float):
	if not is_on_floor():
		footstep_time = 0.0
		return
	footstep_time += delta * footstep_velocity_multiplier.sample(velocity.length() / speed)
	if footstep_time >= 1:
		footstep_audio.play()
		footstep_time = 0.0
