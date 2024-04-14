class_name PlayerController

extends CharacterBody3D

# General Character variables 

@export var BASE_PLAYER_SPEED : float = 3.0
@export var SPRINT_PLAYER_SPEED : float = 5.0
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

# Stair check variables
var was_on_floor_last_frame : bool = false
var snapped_to_stairs_last_frame : bool = false

# Footstep and Headbob variables
@export var BOB_FREQ : float = 2.4
@export var BOB_AMP : float = 0.08
const camera_offset : float = 0.8
var t_bob : float = 0.0
var can_play : bool = true
signal foostep

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
	
	current_player_speed = BASE_PLAYER_SPEED
	
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
		
	if Input.is_action_pressed("sprint"):
		current_player_speed = SPRINT_PLAYER_SPEED
	
	if Input.is_action_just_released("sprint"):
		current_player_speed = BASE_PLAYER_SPEED

	update_camera(delta)
	update_input()
	
	# Headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	CAMERA_CONTROLLER.transform.origin = update_headbob(t_bob)
	
	rotate_step_up_separation_ray()
	update_velocity()
	snap_down_to_stairs_check()
	
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
		
	
	
func update_headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = (sin(time*BOB_FREQ) * BOB_AMP) + camera_offset
	pos.x = cos(time*BOB_FREQ/2) *  BOB_AMP
	
	var low_pos = BOB_AMP - 0.05
	
	#Check if we have reached a high point so we restart can_play
	
	if pos.y > (-low_pos + camera_offset):
		can_play = true
		
	# check if the head position has reached a low point then turn off can play to avoid
	# multiple spam of the emit signal
	
	if pos.y < (-low_pos + camera_offset) and can_play:
		can_play = false
		emit_signal("foostep")
		
	return pos
		
func update_velocity():
	move_and_slide()
	
func interact():
	var collider = FRONT_RAYCAST.get_collider()
	if collider != null:
		if collider.is_in_group("Interactable"):
			collider.interact()
			
func snap_down_to_stairs_check():
	var did_snap = false
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or snapped_to_stairs_last_frame) and $StairCheckRaycast.is_colliding():
		var body_test_result = PhysicsTestMotionResult3D.new()
		var params = PhysicsTestMotionParameters3D.new()
		var max_step_down = -0.4
		params.from = self.global_transform
		params.motion = Vector3(0,max_step_down,0)
		if PhysicsServer3D.body_test_motion(self.get_rid(), params, body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
			
	was_on_floor_last_frame = is_on_floor()
	snapped_to_stairs_last_frame = did_snap
	
@onready var initial_separation_ray_dist = abs($SeperationRayStepUp.position.z)

func rotate_step_up_separation_ray():
	var xz_vel = velocity * Vector3(1,0,1)
	var xz_f_ray_pos = xz_vel.normalized() * initial_separation_ray_dist
	$SeperationRayStepUp.global_position.x = self.global_position.x + xz_f_ray_pos.x
	$SeperationRayStepUp.global_position.z = self.global_position.z + xz_f_ray_pos.z
