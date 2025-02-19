extends Control
class_name Inventory

var player
var drag_origin: Slot = null

func _ready() -> void:
	player = get_parent().get_parent()
