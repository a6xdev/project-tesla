extends Area2D
class_name Item

@onready var texture: Sprite2D = $texture
@onready var item_name_label: Label = $item_name

# =========================================================
# BASE
# =========================================================

enum ItemType {
	STANDARD,
	FIREARM,
	MELEE_WEAPON,
	HEALTH,
	ARMOR
}

@export var item_name: String = "Standard Item"
@export var item_type:ItemType
@export var slot_type: int = 0 ## 0: NONE, 1: HEAD, 2: BODY, 3: LEG, 4: ACTIVE
@export var item_texture:Texture
@export var amount: int = 1
@export var stats: Dictionary = {
	"STRENGHT": 0, ## additional strenght
	"MELEE_ATTACK": 0,  ## Weapon damage ( for melee )
	"GUN_DAMAGE": 0, ## Gun Damage
	"DEF": 0,  ## Defense of an armor
	"DURABILITY": 0,  ## Equipment durability
	"HEALTH": 0 ## Recover health
}

# =========================================================
# GODOT FUNCTIONS
# =========================================================

func _ready() -> void:
	item_name_label.text = str(item_name)
	$texture.texture = item_texture

@rpc("any_peer", "call_local")
func collect(player) -> void:
	if player and player.has_method("InventoryAddItem"):
		player.InventoryAddItem(self)
		rpc("DeleteItem")

@rpc("any_peer", "call_local")
func DeleteItem():
	queue_free()
# =========================================================
# OTHERS
# =========================================================
