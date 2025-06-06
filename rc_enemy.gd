extends VehicleBody3D

const MAX_STEER = 0.3
const MAX_RPM = 200
const MAX_TORQUE = 200
const HORSE_POWER = 100
const REVERSE_POWER = -HORSE_POWER * 2
const STUCK_TIME_THRESHOLD = 0.5

var stuck_timer = 0.0
var is_stuck = false
var laps = 1
var checkpoint = [false, false, false, false]

func reset_checkpoints():
	checkpoint = [false, false, false, false] #[true, true, true, true]
	
func do_lap():
	laps += 1
	reset_checkpoints()
	if laps > 3:
		await get_tree().create_timer (0.25).timeout
		OS.alert("You win!") # replace with level change
	else:
		$Label2.text = "Lap %d/3" % laps
	pass

@onready var rayF = $rayForward
@onready var rayFL = $rayForwardLeft
@onready var rayFR = $rayForwardRight
@onready var rayL = $rayLeft
@onready var rayR = $rayRight

func calc_engine_force(accel, rpm):
	return accel * MAX_TORQUE * (1 - rpm / MAX_RPM)

func check_and_right():
	if global_transform.basis.y.dot(Vector3.UP) < 0:
		var cur_rotation = self.rotation_degrees
		cur_rotation.x = 0 # reset pitch
		cur_rotation.z = 0 # reset roll
		self.rotation_degrees = cur_rotation

func check_stuck_condition(delta):
	if linear_velocity.length() < 1.0:
		stuck_timer += delta
	else:
		stuck_timer = 0
	is_stuck = stuck_timer > STUCK_TIME_THRESHOLD

func update_raycasts():
	rayF.force_raycast_update()
	rayFL.force_raycast_update()
	rayFR.force_raycast_update()
	rayL.force_raycast_update()
	rayR.force_raycast_update()

func is_ray_colliding(raycast: RayCast3D) -> bool:
	return raycast.is_colliding() and raycast.get_collider() is not VehicleBody3D
	

func _physics_process(delta: float) -> void:
	check_stuck_condition(delta)
	
	var target_steering = 0.0
	update_raycasts()
	
	var acceleration = HORSE_POWER
	if is_ray_colliding(rayF):
		var dist_to_obstacle = rayF.get_collision_point().distance_to(global_transform.origin)
		acceleration *= max(0.1, dist_to_obstacle / 10.0)
	if is_ray_colliding(rayFL) or is_ray_colliding(rayL):
		target_steering -= MAX_STEER
	if is_ray_colliding(rayFR) or is_ray_colliding(rayR):
		target_steering += MAX_STEER
	
	# NOTE might want to switch += & -=
	
	target_steering = clamp(target_steering, -MAX_STEER, MAX_STEER)
	if is_stuck:
		acceleration = REVERSE_POWER
		steering = -sign(target_steering) * MAX_STEER
	# else:
		# steering = target_steering

	$backLeft.engine_force = calc_engine_force(acceleration, abs($backLeft.get_rpm()))
	$backRight.engine_force = calc_engine_force(acceleration, abs($backLeft.get_rpm()))
	check_and_right()
	
func _ready() -> void:
	pass
	# remember to add the code from repo!!
