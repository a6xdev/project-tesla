extends Node

@export var player:Player
@export var bullet:PackedScene
@export var muzzle:Marker2D

var weapon_damage = 10
var max_durabilty = 100
var durability = max_durabilty

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority() and player.CanShoot and durability > 0:
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
	bullet_instance.damage = weapon_damage
	durability -= 1
	get_parent().add_child(bullet_instance)
