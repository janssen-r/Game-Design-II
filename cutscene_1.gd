extends Node3D

@onready var alarm = $AudioStreamPlayer3D

func _ready() -> void:
	
	await alarm.finished
	alarm.position = [9.189, 1.413, 9.205]
	alarm.position_x += randf_range(-20,20)
	alarm.position_y += randf_range(-20,20)
	alarm.position_z += randf_range(-20,20)
	
	
	
	await get_tree().create_timer($AnimationPlayer.current_animation_length).timeout
	get_tree().quit()
	
	
