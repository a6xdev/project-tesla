extends TextureRect

@onready var slot: Slot = $".."
@onready var debug_label = %debug

@export var slot_type: int = 0
@export var amount: int = 1:
	set(value):
		amount = value
		if debug_label:
			debug_label.text = str(amount)
var property: Dictionary = {}:
	set(value):
		property = value
		texture = property.get("TEXTURE")
		amount = property.get("AMOUNT", 1)
		slot_type = property.get("SLOT_TYPE", 0)
