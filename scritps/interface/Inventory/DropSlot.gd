extends Slot
class_name DropSlot

const OBJ_ITEM = preload("res://scenes/prefabs/interactive/obj_item.tscn")

var root
var InventoryNode

func _ready() -> void:
	root = get_tree().current_scene.find_child("Items")
	InventoryNode = get_parent().get_parent()

func _physics_process(delta: float) -> void:
	if stored_item and root:
		print(stored_item.get("ITEM_TEXTURE"))
		var data = {
			"ITEM_NAME": stored_item.get("ITEM_NAME"),
			"ITEM_TYPE": stored_item.get("ITEM_TYPE"),
			"SLOT_TYPE": stored_item.get("SLOT_TYPE"),
			"AMOUNT": stored_item.get("AMOUNT"),
			"TEXTURE": stored_item.get("TEXTURE").resource_path,
			"POSITION": InventoryNode.player.global_transform.origin
		}
		rpc("DropItem", data)
		clear_slot()

@rpc("any_peer", "call_local")
func DropItem(data):
	if root == null:
		root = get_tree().current_scene.find_child("Items")

	var item_instance = OBJ_ITEM.instantiate()
	item_instance.item_name = data.get("ITEM_NAME")
	item_instance.item_type = data.get("ITEM_TYPE")
	item_instance.slot_type = data.get("SLOT_TYPE")
	item_instance.amount = data.get("AMOUNT")
	
	var texture_path = data.get("TEXTURE")
	if texture_path != "":
		item_instance.item_texture = load(texture_path)

	item_instance.position = data.get("POSITION")
	root.add_child(item_instance)
