extends Node

@export var lobby_screen: CanvasLayer
@export var options: Control
@export var start: Control
@export var players_count: Control
@export var players_node_ref: Node

@export_group("Server Settings")
@export var IP_ADDRESS:String = "IP ADDRESS"
@export var PORT:int = 135
@export var MAX_CLIENTS:int = 4

@export_group("Settings")
@export var player_scene: PackedScene

var peer = ENetMultiplayerPeer.new()
var players_connected = 0
var players:Array[CharacterBody2D] = []
var can_start: bool = false
var game_started: bool = false

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _physics_process(_delta):
	if multiplayer.is_server() and can_start:
		players_count.show()
		players_count.text = str(players_connected) + " / " + str(MAX_CLIENTS)
		if players_connected >= 2:
			start.show()
	else:
		start.hide()
		players_count.hide()

func host_pressed():
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	players_connected = 1
	can_start = true
	options.hide()

	_add_player(multiplayer.get_unique_id())

func join_pressed():
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	options.hide()

func start_pressed():
	if players_connected >= 1:
		game_started = true
		lobby_screen.hide()

func _on_player_connected(id):
	if game_started or players_connected >= MAX_CLIENTS:
		print("Error: Match has already started or maximum number reached")
		multiplayer.disconnect_peer(id)
		return

	players_connected += 1
	print("New Player: ", id)
	
	if multiplayer.is_server():
		_add_player.rpc(id)
		for player in players_node_ref.get_children():
			var player_id = int(str(player.name))
			_add_player.rpc_id(id, player_id)

func _on_player_disconnected(id):
	players_connected -= 1
	print("Player left: ", id)
	_remove_player.rpc(id)

	if multiplayer.has_multiplayer_peer() and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		print("Peer disconnected: ", id)

@rpc("any_peer", "call_local")
func _add_player(id):
	if id == multiplayer.get_unique_id() and players_node_ref.has_node(str(id)):
		return

	var player = player_scene.instantiate()
	player.name = str(id)

	var spawn_area = Rect2(Vector2(100, 100), Vector2(500, 500))
	var spawn_position = Vector2(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	)
	player.position = spawn_position

	players_node_ref.add_child(player)
	print("Player added: ", id)

@rpc("any_peer", "call_local")
func _remove_player(id):
	var player = players_node_ref.get_node_or_null(str(id))
	if player:
		player.queue_free()
		print("Player removed: ", id)

func _game_over():
	game_started = false
	lobby_screen.show()
