class_name Pickup_Component

extends Node

@export var MAIN_RAYCAST : RayCast3D
@export var GROUND_RAYCAST : RayCast3D

@export var PICKED_UP_POSITION : Marker3D
var can_pickup : bool = true
var collider_group : StringName
var drop_object_position : Vector3

var can_inspect : bool = true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	
	if can_pickup:
		if Input.is_action_just_pressed("interact_button"):
			detect_object()
	else:
		var drop_check = drop_object_check()
		if drop_check and Input.is_action_just_pressed("interact_button"):
			unequip_object(drop_object_position)

func detect_object():
	var collider = MAIN_RAYCAST.get_collider()
	
	if collider != null:
		print("There are items that have collided")
		if collider.is_in_group("Item_PickedUp") and (collider is Area3D or collider is StaticBody3D):
			print("Item to be picked up detected")
			if can_pickup:
				equip_object(collider)
		

func equip_object(collided_object):
	can_pickup = false
	collided_object.get_parent().queue_free()
	var temp_item = Global.test_pickup_item.instantiate()
	PICKED_UP_POSITION.add_child(temp_item)
	
	temp_item.global_position = PICKED_UP_POSITION.global_position
	temp_item.global_rotation = PICKED_UP_POSITION.global_rotation
	temp_item.get_child(1).collision_layer = 0
	
	
	
func unequip_object(position_to_drop):
	can_pickup = true
	var new_item = Global.test_pickup_item.instantiate()
	get_tree().get_root().add_child(new_item)
	new_item.global_position = position_to_drop
	new_item.global_rotation = Vector3(0,PICKED_UP_POSITION.global_rotation.y,0)
	PICKED_UP_POSITION.get_child(0).queue_free()
	
func drop_object_check() -> bool:
	var ground_collider = GROUND_RAYCAST.get_collider()
	var platform_collider = MAIN_RAYCAST.get_collider()
	var check_status : bool = false
	
	
	if platform_collider != null:
		print("The item can be dropped on the platform here")
		if platform_collider.is_in_group("Platform") and MAIN_RAYCAST.get_collision_normal() == Vector3.UP:
			var pos = MAIN_RAYCAST.get_collision_point()
			# below is deprecated for the time being
			#var height_offset = platform_collider.global_transform.basis.y.length() / 2 
			var alt_height_offset = PICKED_UP_POSITION.get_child(0).global_transform.basis.y.length() / 2
			drop_object_position = Vector3(pos.x,pos.y + alt_height_offset,pos.z)
			check_status = true
			print(check_status)
			return check_status
		else:
			check_status = false
			print(check_status)
			return check_status
			
	elif ground_collider != null:
		print("The item can be dropped on the ground here")
		if ground_collider.is_in_group("Ground"):
			var pos = GROUND_RAYCAST.get_collision_point()
			var height_offset = ground_collider.global_transform.basis.y.length() / 2
			drop_object_position = Vector3(pos.x,pos.y + height_offset,pos.z)
			check_status = true
			print(check_status)
			return check_status
		else:
			check_status = false
			print(check_status)
			return check_status
		
	else:
		check_status = false
		print(check_status)
		return check_status
			
	
		
	
func collect_object():
	pass
