extends VehicleBody3D

const MAX_STEER = 0.3
const MAX_RPM = 200
const MAX_TORQUE = 200
const HORSE_POWER = 100
const MAX_BOOST = 100
const QUICK_TURN_BOOST_REGEN = 2

var DEFAULT_BOOST_REGEN = 1


var cur_max_steer
var cur_max_rpm

var boost_fuel = MAX_BOOST / 2
var boost_regen = 1

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func calc_engine_force(accel, rpm):
	return accel * MAX_TORQUE * (1 - rpm / cur_max_rpm)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

	if Input.is_action_pressed("ui_accept"):
		cur_max_steer = 1
		cur_max_rpm = MAX_RPM - 30
		boost_regen = QUICK_TURN_BOOST_REGEN
		if $boostDecay.timeout and Input.is_action_pressed("boost") == false:
			if boost_fuel < MAX_BOOST: boost_fuel += boost_regen
			$boost.text = str(boost_fuel)
	elif Input.is_action_pressed("boost") and boost_fuel > 0:
		cur_max_rpm = MAX_RPM + 50
		if $boostDecay.timeout:
			boost_fuel -= 1
			$boost.text = str(boost_fuel)
	else:
		cur_max_steer = MAX_STEER
		cur_max_rpm = MAX_RPM
		boost_regen = DEFAULT_BOOST_REGEN
		if $boostDecay.timeout and Input.is_action_pressed("boost") == false:
			if boost_fuel < MAX_BOOST: boost_fuel += boost_regen
			$boost.text = str(boost_fuel)

	steering = lerp(steering, Input.get_axis("ui_right", "ui_left") * cur_max_steer, delta * 5.0)
	var accel = Input.get_axis("ui_down", "ui_up") * HORSE_POWER
	$backLeft.engine_force = calc_engine_force(accel, abs($backLeft.get_rpm()))
	$backRight.engine_force = calc_engine_force(accel, abs($backLeft.get_rpm()))
	
	var fwd_mps = abs((linear_velocity * transform.basis).z)
	$Label.text = "%d mph" % (fwd_mps * 2.23694)
	
	$centerMass.global_position = $centerMass.global_position.lerp(global_position, delta * 20.0)
	$centerMass.transform = $centerMass.transform.interpolate_with(transform, delta * 5.0)
	
	$centerMass/Camera3D.look_at(global_position.lerp(global_position + linear_velocity, delta * 5.0))

# TODO SOUND!!!
	if accel > 0:
		var max_dB = 110
		var dB = clamp(max_dB * abs($backLeft.engine_force/MAX_RPM), -10, max_dB)
		$AudioStreamPlayer3D.volume_db = dB
	if not $AudioStreamPlayer3D.is_playing():
		pass # change the stream to the vroom sound and play
	else:
		$AudioStreamPlayer3D.volume_db = 10  # default
	# change the stream to the idle sound and play

	check_and_right()

func check_and_right():
	if global_transform.basis.y.dot(Vector3.UP) < 0:
		var cur_rotation = self.rotation_degrees
		cur_rotation.x = 0 # reset pitch
		cur_rotation.z = 0 # reset roll
		self.rotation_degrees = cur_rotation


func _on_boost_decay_timeout() -> void:
	pass
	#if Input.is_action_pressed("boost") == false:
		#boost_fuel += boost_regen
