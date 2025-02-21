extends Area2D
class_name Bullet

@onready var destroy_timer = $DestroyTimer

@export var speed: float = 1000
@export var direction: Vector2 = Vector2.RIGHT

var damage:int = 10
var shooter
var in_vehicle:bool = false

func _ready():
	destroy_timer.start()
	
func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body != shooter:
		if body is Enemy:
			body.target = shooter
			body.SetDamage(damage)
		if body is Player:
			body.SetDamage(damage)
		rpc("destroy_bullet")

func _on_destroy_timer_timeout():
	rpc("destroy_bullet")

@rpc("call_local", "any_peer")
func destroy_bullet():
	queue_free()
