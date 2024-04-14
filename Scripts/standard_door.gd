class_name StandardDoor

extends StaticBody3D

@export var IS_OPEN : bool = false
@export var IS_LOCKED : bool = false
@export var NEEDS_KEY : bool = false
@export var KEY_NEEDED : String
var in_animation : bool = false

@export var AUDIO_PLAYER : AudioStreamPlayer3D
@export var door_open_sounds_mp3 : Array[AudioStreamMP3]

var player_at_door : bool = false

var tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_tween_finished():
	IS_OPEN = !IS_OPEN
	in_animation = false

func interact():
	print("attempt to open door")
	if in_animation == false:
		tween = create_tween()
	
		if player_at_door:
			if IS_LOCKED:
				if NEEDS_KEY:
					if !is_instance_valid(KEY_NEEDED):
						IS_LOCKED = false
						open_door()
	
			elif IS_OPEN == false and in_animation == false:
				open_door()
			elif IS_OPEN and !in_animation:
				close_door()
				await get_tree().create_timer(0.5).timeout
				set_collision_layer_value(9, true)
	
func open_door():
	tween.tween_property(self, "rotation_degrees", Vector3(0,rotation_degrees.y, 0), 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", Vector3(0,rotation_degrees.y + 90, 0), 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#tween.parallel().tween_property($MeshInstance3D, "rotation_degrees", Vector3(0,rotation_degrees.y, 0), 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#tween.parallel().tween_property($MeshInstance3D, "rotation_degrees", Vector3(0,rotation_degrees.y + 90, 0), 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	in_animation = true
	tween.play()
	play_open_sound()
	set_collision_layer_value(9, false)
	tween.connect("finished", on_tween_finished)
	#get_tree().create_timer(3.0).timeout
	
	
	
func close_door():
	tween.tween_property(self, "rotation_degrees", Vector3(0,rotation_degrees.y, 0), 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", Vector3(0,rotation_degrees.y - 90, 0), 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#tween.parallel().tween_property($MeshInstance3D, "rotation_degrees", Vector3(0,rotation_degrees.y, 0), 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#tween.parallel().tween_property($MeshInstance3D, "rotation_degrees", Vector3(0,rotation_degrees.y - 90, 0), 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	in_animation = true
	tween.play()
	tween.connect("finished", on_tween_finished)
	

func play_open_sound():
	var random_index : int = randi_range(0,door_open_sounds_mp3.size() - 1)
	AUDIO_PLAYER.stream = door_open_sounds_mp3[random_index]
	AUDIO_PLAYER.pitch_scale = randf_range(0.8,1.2)
	AUDIO_PLAYER.play()


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("player is at door")
		player_at_door = true


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("player left door")
		player_at_door = false
