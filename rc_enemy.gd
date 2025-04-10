extends VehicleBody3D

func _ready() -> void:
	var mesh_instance = $body as MeshInstance3D
	var mesh = mesh_instance.mesh

	# Get the existing material or create a new one
	var material = mesh.surface_get_material(0)
	if material == null or not material is StandardMaterial3D:
		material = StandardMaterial3D.new()
		mesh.surface_set_material(0, material)

	# Clone the material so changes don't affect other instances
	material = material.duplicate() as StandardMaterial3D
	mesh.surface_set_material(0, material)

	# Generate a random color
	# TODO var random_color = Color.from_hsv(). RANDOMIZE HUE!!

	# Assign it to the albedo
	# TODO material.albedo_color = random_color
