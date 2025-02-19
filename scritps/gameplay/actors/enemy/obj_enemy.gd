extends CharacterBody2D
class_name Enemy

@onready var patrol_timer: Timer = $PatrolTimer
@onready var attack_timer: Timer = $AttackTimer

var target: Node2D = null
var attack_target:Node2D = null

@export_group("Entity Settings")
@export var health: int = 100
@export var damage: int = 10
@export var xp_drop: int = 10

@export_group("Entity Behavior")
@export var PLAYER_VISIBLE: bool = true
@export var CAN_WALK: bool = true

@export_group("Entity Speed")
@export var patrol_speed: float = 50
@export var chase_speed: float = 300

var is_waiting: bool = false
var is_chasing: bool = false
var is_attacking:bool = false
var in_vehicle:bool = false

var patrol_target_position: Vector2

# /////////////
# /// Funções ///
# /////////////
func _ready():
	set_random_patrol_target()

func _physics_process(delta: float) -> void:
	movement_behavior()
		
	$health.text = "HEALTH: " + str(health)
	
	if target:
		if target.IsInVehicle:
			target = null
			is_chasing = false
		if target.IsDead:
			target = null
			is_chasing = false
	
	if target and not is_attacking and attack_target:
		attack_target.SetDamage(damage)
		attack_timer.start()
		is_attacking = true
	

# ////////////////
# /// Behavior ///
# ////////////////
func movement_behavior():
	if target and is_chasing:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * chase_speed
		move_and_slide()
	else:
		if not is_waiting:
			var direction = (patrol_target_position - global_position).normalized()
			velocity = direction * patrol_speed
			
			if global_position.distance_to(patrol_target_position) < 10:
				is_waiting = true
				velocity = Vector2.ZERO
				patrol_timer.start()
		move_and_slide()

# ////////////////
# /// Mechanic ///
# ////////////////
func SetDamage(value: int):
	if multiplayer.is_server():
		if target:
			is_chasing = true
		
		health -= value
		if health <= 0:
			rpc("destroy_enemy")

@rpc("any_peer", "call_local")
func destroy_enemy():
	if target:
		target.ExperienceSystem(xp_drop)
	queue_free()

func set_random_patrol_target():
	var random_angle = randf_range(0, 2 * PI)
	var random_distance = randf_range(50, 500)
	patrol_target_position = global_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance

# ///////////////
# /// Signals ///
# ///////////////
func _detect_player_entered(body: Node2D) -> void:
	if body is Player:
		if target == null and not body.IsInVehicle:
			is_chasing = true
			target = body

func _attack_entered(body: Node2D) -> void:
	if body is Player:
		attack_target = body

func _attack_exited(body: Node2D) -> void:
	if body is Player:
		attack_target = null

func _attack_timeout() -> void:
	is_attacking = false
func _patrol_timeout() -> void:
	is_waiting = false
	set_random_patrol_target()
