extends Actor
# Player object
# Processes player inputs and interactions


# Crouching related
export var crouch_rate: float = 0.25
export var crouch_factor: float = 0.4
export var crouch_complete_factor: float = 0.01
# Node Paths
export var body_path: NodePath # Collision Shape
export var pivot_path: NodePath # Spatial
export var wall_detector_path: NodePath # Area
export var floor_detector_path: NodePath # Area
export var ceiling_detector_path: NodePath # Area

# Jumping related
var _jump: bool = false
# Crouching related
var _crouch: bool = false
var _crouch_complete: bool = false
var _crouch_vector: Vector3 = Vector3(0, crouch_factor, 0)
# Collision detectors
var _wall_blocked: bool = false
var _floor_below: bool = false
var _ceiling_above: bool = false
# Mouse rotation and movement input
var _turn_factor: float = 0.0
var _movement_inputs: Vector2 = Vector2.ZERO

# Body node and properties
onready var _body: CollisionShape = get_node(body_path)
onready var _body_extents: Vector3 = _body.shape.extents
onready var _body_original_extents: Vector3 = _body_extents
# Rotation pivot (holds the camera)
onready var _pivot: Spatial = get_node(pivot_path)
# Detectors
onready var _wall_detector: Area = get_node(wall_detector_path)
onready var _floor_detector: Area = get_node(floor_detector_path)
onready var _ceiling_detector: Area = get_node(ceiling_detector_path)


# Handle input
func _unhandled_input(event: InputEvent) -> void:
	
	# Movement inputs
	_movement_inputs.x = (Input.get_action_strength("move_backward") 
			- Input.get_action_strength("move_forward"))
	_movement_inputs.y = (Input.get_action_strength("strafe_right") 
			- Input.get_action_strength("strafe_left"))
	
	# Mouse look
	if event is InputEventMouseMotion:
		_turn_factor = event.relative.x * Globals.MOUSE_SENS
		_pivot.change_rotation(deg2rad(-event.relative.y * Globals.MOUSE_SENS), 
				deg2rad(-_turn_factor))
	
	# Set input as handled
	get_tree().set_input_as_handled()


# Process physics
func _physics_process(_delta: float) -> void:
	
	# Reset floor, wall and ceiling checks
	_floor_below = _floor_detector.detected
	_wall_blocked = _wall_detector.detected
	_ceiling_above = _ceiling_detector.detected
	
	# Crouch input, called here to sync with _ceiling_above
	if _ceiling_above:
		_crouch = true
	else:
		_crouch = Input.is_action_pressed("crouch")
	
	# Crouching
	if _crouch:
		_body_extents = _body_extents.linear_interpolate(
				_body_original_extents - _crouch_vector, crouch_rate)
		_wall_detector.change_extents(-_crouch_vector, crouch_rate)
		_ceiling_detector.change_extents(_crouch_vector, crouch_rate)
		_floor_detector.change_translation(_crouch_vector, crouch_rate)
	# Standing
	else:
		_body_extents = _body_extents.linear_interpolate(
				_body_original_extents, crouch_rate)
		_wall_detector.change_extents(Vector3.ZERO, crouch_rate)
		_ceiling_detector.change_extents(Vector3.ZERO, crouch_rate)
		_floor_detector.change_translation(Vector3.ZERO, crouch_rate)
	
	# Update body shape
	_body.shape.set_deferred("extents", _body_extents)
	
	# Check if crouch is complete
	_crouch_complete = (_body.shape.extents.y - (
			_body_original_extents.y - crouch_factor) < crouch_complete_factor)
	
	# Jump input, called here to register on just one frame
	if (
			not (_crouch_complete and is_on_floor())
	):
		_jump = Input.is_action_just_pressed("jump")
	
	# Call movement function on Actor class
	move(_movement_inputs, _jump, _crouch, _crouch_complete,
			_wall_blocked, _floor_below, 
			_pivot.rotation.y, _turn_factor)
