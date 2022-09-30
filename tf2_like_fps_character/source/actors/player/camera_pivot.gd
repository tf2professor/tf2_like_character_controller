extends Spatial
# Pivot to rotate and control camera


export var camera_clamp: float = 90.0
export var fp_camera_path: NodePath
export var tp_camera_path: NodePath

onready var _fp_camera: Camera = get_node(fp_camera_path)
onready var _tp_camera: Camera = get_node(tp_camera_path)


func _unhandled_input(_event: InputEvent) -> void:
	# Change camera
	# By default, "change_camera" is the P key
	if Input.is_action_just_pressed("change_camera"):
		_tp_camera.set_deferred("current", !_tp_camera.current)
		get_tree().set_input_as_handled()


func change_rotation(x: float, y: float) -> void:
	# Rotate camera and pivot
	_fp_camera.rotate_x(x)
	_fp_camera.rotation.x = clamp(_fp_camera.rotation.x, 
			deg2rad(-camera_clamp), deg2rad(camera_clamp))
	rotate_y(y)
