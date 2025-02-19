extends CanvasLayer

func _ready() -> void:
	if is_multiplayer_authority():
		visible = true
	
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("a_inventory"):
			$Inventory.visible = !$Inventory.visible
			get_parent().InInventory != get_parent().InInventory

func _respawn_pressed() -> void:
	var player = get_parent()
	player.rpc("RespawnPlayer")
