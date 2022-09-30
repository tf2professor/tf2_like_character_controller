class_name Actor
extends KinematicBody
# Actor class for characters that need to move under the same rules


# Horizontal movement related
export var base_speed: float = 7.0
export var crouch_speed_factor: float = 0.33
export var backwards_speed_factor: float = 0.9
export var acceleration: float = 0.09
# Vertical movement related
export var jump_power: float = 7.0
export var not_on_floor_penalty_factor: float = 5.5
export var air_impulse: float = 1.0
export var air_brake: float = 1.25
export var air_strafe_factor: float = 5.0
export var step_up_power: float = 2.5
export var step_up_speed_min: float = 0.75
# Rotation and turning related
export var min_turn_factor: float = 0.1
export var max_turn_factor: float = 8.0
export var stagger_factor: float = 1.1
export var air_rotation_treshold: float = 0.05
# Floor contact related
export var max_floor_angle: float = 45.0
export var snap_factor: float = 5.0

# Jumping check
var _jumping: bool = false
# Global variables for managing movement
var _speed: float = 0.0
var _rotation: float = 0.0
var _jump_not_on_floor_penalty: float = jump_power / not_on_floor_penalty_factor
var _move_vector: Vector2 = Vector2.ZERO
var _snap_vector: Vector3 = Vector3.ZERO
var _velocity: Vector3 = Vector3.ZERO


# Execute movement
func move(movement_inputs: Vector2, jump: bool, crouch: bool, 
		crouch_complete: bool, wall_blocked: bool, floor_below: bool,
		pivot_rotation: float, turn_factor: float) -> void:
	
	# PREPARATIONS #############################################################
	# Check if jump landed
	if _jumping and is_on_floor():
		_jumping = false
	
	# Update move vector
	if not movement_inputs == Vector2.ZERO:
		if (
				is_on_floor() 
				or is_on_wall()
		):
			_move_vector = movement_inputs
	
	# Calculate target speed
	var target_speed: float = 0.0
	if floor_below:
		if not movement_inputs == Vector2.ZERO:
			# Default ground standing speed
			target_speed = base_speed
		if is_on_floor():
			if crouch_complete:
				# Crouch speed
				target_speed *= crouch_speed_factor
			elif movement_inputs.x > 0:
				# Moving backwards speed
				target_speed *= backwards_speed_factor
		elif crouch:
			# Crouch speed
			target_speed *= crouch_speed_factor
	
	# Accelerate speed to match target
	if (
			is_on_floor() 
			or is_on_wall()
	):
		_speed = lerp(_speed, target_speed, acceleration)
	###########################################################################
	
	# HORIZONTAL VELOCITY #####################################################
	# Air impulse and brake
	if (
			not is_on_floor()
			and not movement_inputs == Vector2.ZERO
	):
		if _speed < air_impulse:
			# Impulse from a stand still
			_move_vector = movement_inputs
			_speed = air_impulse
		else:
			# Speed changes mid air
			if (
					not movement_inputs.x == 0.0 
					and movement_inputs.y == 0.0
			):
				# Forward and backward direction checks
				if movement_inputs.x == -sign(_move_vector.x):
					# Input is opposite to movement vector
					_speed /= air_brake
				elif (
						not _move_vector.y == 0.0 
						and not _move_vector.length() > 1.0
				):
					# Input is perpendicular to movement vector and not diagonal
					_move_vector.x = movement_inputs.x / air_strafe_factor
			if (
					not movement_inputs.y == 0.0 
					and movement_inputs.x == 0.0
			):
				# Sideways direction checks
				if movement_inputs.y == -sign(_move_vector.y):
					# Input is opposite to movement vector
					_speed /= air_brake
				elif (
						not _move_vector.x == 0.0 
						and not _move_vector.length() > 1.0
				):
					# Input is perpendicular to movement vector and not diagonal
					_move_vector.y = movement_inputs.y / air_strafe_factor
			if abs(turn_factor) > max_turn_factor:
				# Stagger on air if moving mouse too fast
				_speed /= stagger_factor
	
	# Horizontal velocity vector
	var _velocity_vector: Vector2 = _move_vector.normalized()
	_velocity.x = _velocity_vector.y * _speed
	_velocity.z = _velocity_vector.x * _speed
	
	# Rotate velocity vector
	if not movement_inputs == Vector2.ZERO:
		# Ground rotation checks
		if (
				floor_below 
				or _speed <= air_impulse
		):
			_rotation = pivot_rotation
		# Airborne rotation checks, for air strafing
		elif (
				# Not pressing either W or S
				movement_inputs.x == 0.0 
				# Pressing strafe keys and moving mouse in the same direction
				# Multiply sign(-_move_vector.x) to be able to strafe backwards
				and (abs(turn_factor) > min_turn_factor 
						and sign(turn_factor) * sign(-_move_vector.x)
								 == movement_inputs.y)
				# Velocity rotation is under allowed limit
				# This avoids strafing at impossible angles
				and (_velocity.rotated(Vector3.UP, pivot_rotation).normalized().dot(
							_velocity.rotated(Vector3.UP, _rotation).normalized()
						) > 1.0 - air_rotation_treshold)
		):
			_rotation = pivot_rotation
	# Rotate velocity vector accordingly
	_velocity = _velocity.rotated(Vector3.UP, _rotation)
	###########################################################################
	
	# VERTICAL VELOCITY #######################################################
	# Snap to floor and movement corrections/fixes
	if is_on_floor():
		_snap_vector = -get_floor_normal()
		# Prevent sliding on slopes after jumping/falling
		if _velocity.y < 0.0:
			_velocity.y = 0.0
	else:
		# Prevent jumping up when going off platforms #
		if (
				not _snap_vector == Vector3.ZERO 
				and not _velocity.y == 0.0
		):
			_velocity.y = 0.0
		_snap_vector = Vector3.ZERO
	
	# Vertical velocity vector
	var gravity: float = Globals.GRAVITY
	if not is_on_floor():
		_velocity.y -= gravity
	
	# Step up stairs and small obstacles
	if (
			is_on_wall() 
			and _speed > step_up_speed_min 
			and not wall_blocked 
			and not _jumping
	):
		_snap_vector = Vector3.ZERO
		_velocity.y = step_up_power
	
	# Jump
	if jump:
		if (
				is_on_floor() 
				or floor_below
		):
			_jumping = true
			_snap_vector = Vector3.ZERO
			if is_on_floor():
				_velocity.y = jump_power
			else:
				_velocity.y = jump_power - _jump_not_on_floor_penalty
	###########################################################################
	
	# EXECUTE MOVEMENT AND UPDATE VELOCITY VARIABLE ###########################
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector / snap_factor, 
			Vector3.UP, true, 4, deg2rad(max_floor_angle))
	###########################################################################
