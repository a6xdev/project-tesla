extends Slot
class_name PassiveSlot

@export var firearm_system_node:Node

func _physics_process(delta: float) -> void:
	var inventory = get_parent().get_parent()
	
	if stored_item.get("ITEM_TYPE") == 1:
		inventory.player.CanShoot = true
		firearm_system_node.weapon_damage = stored_item["STATS"].get("GUN_DAMAGE")
		firearm_system_node.max_durabilty = stored_item["STATS"].get("MAX_DURABILITY")
	else:
		inventory.player.CanShoot = false
		
	#if stored_item.get("SLOT_TYPE") == 1:
		#inventory.player.DefenseValue = stored_item["STATS"].get("DEF")

func _can_drop_data(_pos, data):
	return data is Dictionary and data.get("SLOT_TYPE") == slot_type
