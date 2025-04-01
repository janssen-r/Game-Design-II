extends Node3D

func _physics_process(delta: float) -> void:
	pass #if $giant_tree.get_children() and is_in_group("breakable") and .overlaps_area():
		
