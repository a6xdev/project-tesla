extends Node

@export var player:Player
@export var bullet:PackedScene
@export var muzzle:Marker2D

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority() and player.CanShoot:
		if Input.is_action_just_pressed("a_shoot"):
			var bullet_direction = Vector2.RIGHT.rotated(player.rotation)
			rpc("shoot", bullet_direction)

@rpc("call_local", "any_peer")
func shoot(bullet_direction: Vector2):
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = muzzle.global_transform.origin
	bullet_instance.direction = bullet_direction
	bullet_instance.shooter = player
	bullet_instance.in_vehicle = false
	get_parent().add_child(bullet_instance)
