class_name BodyDetector
extends Area
# Detects bodies
# Used for player crouching, jumping and stepping up obstacles
# Must be attached to an area node


var detected: bool
var _bodies: int

onready var _shape: CollisionShape = get_child(0)
onready var _original_translation: Vector3 = _shape.translation
onready var _original_extents: Vector3 = _shape.shape.extents
onready var _translation: Vector3 = _original_translation
onready var _extents: Vector3 = _original_extents


func _ready() -> void:
	# Connect signals
	var _signal
	_signal = connect("body_entered", self, "_on_body_entered")
	_signal = connect("body_exited", self, "_on_body_exited")


func _physics_process(_delta: float) -> void:
	# Update detected variable
	detected = _bodies > 0
	
	# Update shape extents and translation
	_shape.shape.set_deferred("extents", _extents)
	_shape.set_deferred("translation", _translation)


func change_extents(factor: Vector3, weight: float) -> void:
	# Interpolate extents
	_extents = _extents.linear_interpolate(_original_extents + factor, weight)


func change_translation(factor: Vector3, weight: float) -> void:
	# Interpolate translation
	_translation = _translation.linear_interpolate(
			_original_translation + factor, weight)


func _on_body_entered(_body: Node) -> void:
	_bodies += 1


func _on_body_exited(_body: Node) -> void:
	_bodies -= 1
