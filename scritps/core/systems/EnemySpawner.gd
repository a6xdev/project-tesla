extends Marker2D
class_name EnemySpawner

@export var LobbyManager: Node
@export var enemy_scene: PackedScene
@export var active:bool = false
@export var spawn_area: Rect2 = Rect2(Vector2(100, 100), Vector2(500, 500))
@export var enemies_per_wave: int = 5
@export var wave_delay: float = 3.0  # Tempo de espera para a próxima horda

var enemies = []
var waiting_next_wave = false  # 🔹 Evita chamadas repetidas

func _ready():
	if multiplayer.is_server():
		if active:
			spawn_wave()

func _physics_process(delta):
	if LobbyManager.GameStarted and multiplayer.is_server() and active:
		if enemies.is_empty() and not waiting_next_wave:
			waiting_next_wave = true 
			await get_tree().create_timer(wave_delay).timeout
			spawn_wave.rpc()

@rpc("authority", "call_local")
func spawn_wave():
	if not multiplayer.is_server():
		return

	waiting_next_wave = false
	for i in range(enemies_per_wave):
		var enemy = enemy_scene.instantiate()
		enemy.position = Vector2(
			randf_range(spawn_area.position.x, spawn_area.end.x),
			randf_range(spawn_area.position.y, spawn_area.end.y)
		)
		add_child(enemy)
		enemies.append(enemy)
		enemy.tree_exited.connect(func(): enemies.erase(enemy))
