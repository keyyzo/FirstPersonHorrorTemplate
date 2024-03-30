extends Node3D

@export var canvas : CanvasLayer
@export var interact_label : Label3D
@export var Detection_Area : Area3D

var dialogue_activated : bool = false 
var player_within_area : bool = false



func _ready() -> void:
	canvas.hide()
	interact_label.hide()
	
func  _process(delta: float) -> void:
	if dialogue_activated:
		canvas.show()
	else:
		canvas.hide()
	
	if player_within_area == true and dialogue_activated == false:
		if Input.is_action_just_pressed("interact_button"):
			dialogue_activated = true
			interact_label.hide()
	elif dialogue_activated:
		if Input.is_action_just_pressed("interact_button"):
			dialogue_activated = false
			interact_label.show()
	
	
func activate_dialogue():
	dialogue_activated = true

func deactivate_dialogue():
	dialogue_activated = false
	
func get_dialogue_active() -> bool:
	return dialogue_activated


func _on_detection_area_area_entered(area: Area3D) -> void:
	print("Area has detected something")
	if area.is_in_group("main_raycast"):
		print("Main raycast detected")
	elif area.is_in_group("player"):
		print("Player detected")


func _on_detection_area_body_entered(body: Node3D) -> void:
	print("Body has detected something")
	if body.is_in_group("main_raycast"):
		print("Main raycast detected")
	elif body.is_in_group("player"):
		print("Player detected")
		player_within_area = true
		interact_label.show()


func _on_detection_area_body_exited(body: Node3D) -> void:
	player_within_area = false
	dialogue_activated = false
	interact_label.hide()
