extends Node
# Global variables


# Input related
const MOUSE_SENS: float = 0.025

# World properties and physics values
const GRAVITY: float = 0.3


func _ready() -> void:
	# Capture mouse
	Input.set_mouse_mode(2)
