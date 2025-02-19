extends PanelContainer
class_name Slot

@onready var texture_rect = $TextureRect
@onready var label = %debug

@export_enum("NONE:0","HEAD:1","BODY:2","LEG:3", "ACTIVE:4") var slot_type : int
var stored_item: Dictionary = {}
var drag_item: Dictionary = {}
var drag_origin: Slot = null

func _get_drag_data(at_position):
	if texture_rect.texture != null:
		set_drag_preview(get_preview())
		drag_item = stored_item.duplicate(true)
		var inventory = get_parent().get_parent()
		if inventory:
			inventory.drag_origin = self
		return drag_item
	return null

func _can_drop_data(_pos, data):
	return data is Dictionary and texture_rect.texture == null

func _drop_data(_pos, data):
	var inventory_grid = get_parent()
	var inventory = get_parent().get_parent()
	var slot_under_mouse = null
	
	for slot in inventory_grid.get_children():
		if slot is Slot and slot.get_global_rect().has_point(get_global_mouse_position()):
			slot_under_mouse = slot
			break

	var drag_origin = inventory.drag_origin

	if slot_under_mouse and slot_under_mouse._can_drop_data(_pos, data):
		if drag_origin:
			drag_origin.clear_slot()
		slot_under_mouse.set_item(data)
	else:
		if drag_origin:
			drag_origin.set_item(drag_item)

	inventory.drag_origin = null
	drag_item = {}

func set_item(item_data: Dictionary):
	stored_item = item_data
	texture_rect.texture = item_data.get("TEXTURE")
	texture_rect.property = item_data
	update_label()

func clear_slot():
	stored_item = {}
	texture_rect.texture = null
	update_label()

func update_label():
	if stored_item and stored_item.get("AMOUNT", 1) > 1:
		label.text = str(stored_item.get("AMOUNT"))
	else:
		label.text = ""

func get_preview():
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_texture.size = Vector2(30, 30)

	var preview = Control.new()
	preview.add_child(preview_texture)

	return preview

func restore_item(item_data: Dictionary):
	if drag_origin:
		drag_origin.set_item(item_data)
