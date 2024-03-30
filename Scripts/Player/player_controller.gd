class_name PlayerController

extends CharacterBody3D

# General Character variables 

@export var PLAYER_SPEED : float = 5.0
@export var PLAYER_ACCELERATION : float = 0.1
@export var PLAYER_DECELERATION : float = 0.25

@export var PLAYER_ANIMATIONS : AnimationPlayer

var current_player_speed : float

const JUMP_VELOCITY = 4.5 # May get deleted if no jumping will be involved in the template

# Camera variables
@export var MOUSE_SENS : float = 0.50
@export var TILT_LOWER_LIMIT := deg_to_rad(-90)
@export var TILT_UPPER_LIMIT := deg_to_rad(90)
@export var CAMERA_CONTROLLER : Camera3D
@export var FRONT_RAYCAST : RayCast3D

var mouse_input : bool = false
var mouse_rotation : Vector3
var rotation_input : float
var tilt_input : float
var player_rotation : Vector3
var camera_rotation : Vector3
var current_rotation : float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		rotation_input = -event.relative.x * MOUSE_SENS
		tilt_input = -event.relative.y * MOUSE_SENS

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	current_player_speed = PLAYER_SPEED
	
	Global.Player = self

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("interact_button"):
		interact()

	update_camera(delta)
	update_input()
	update_velocity()
	
func update_camera(delta):
	# Rotate camera using eular rotation
	
	current_rotation = rotation_input
	mouse_rotation.x += tilt_input * delta
	mouse_rotation.x = clamp(mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouse_rotation.y += rotation_input * delta
	
	player_rotation = Vector3(0.0, mouse_rotation.y, 0.0)
	camera_rotation = Vector3(mouse_rotation.x, 0.0,0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(player_rotation)
	
	rotation_input = 0.0
	tilt_input = 0.0
	
func update_input():
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		
		velocity.x = lerp(velocity.x, direction.x * current_player_speed, PLAYER_ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * current_player_speed, PLAYER_ACCELERATION)
		
	else:
		var vel = Vector2(velocity.x,velocity.z)
		var temp = move_toward(Vector2(velocity.x, velocity.z).length(), 0, PLAYER_DECELERATION)
		velocity.x = vel.normalized().x * temp
		velocity.z = vel.normalized().y * temp
		
func update_velocity():
	move_and_slide()
	
func interact():
	var collider = FRONT_RAYCAST.get_collider()
	if collider != null:
		if collider.is_in_group("Interactable"):
			collider.interact()
