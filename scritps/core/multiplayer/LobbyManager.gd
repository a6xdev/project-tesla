extends Node
class_name LobbyManager

@export_group("Server Settings")
@export var IP_ADDRESS:String = "127.0.0.1"
@export var PORT:int = 12345
@export var MAX_CLIENTS:int = 4

@export_group("Player Settings")
@export var PlayersNode:Node
@export var PlayerScene: PackedScene

var PlayerConnected = 0
var PlayersList:Array[Player] = []

var CanStart:bool = false
var GameStarted:bool = false
signal GameStart

# ///////////////// GODOT FUNCTIONS /////////////////
func _ready():
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)

# ///////////////// LOBBY /////////////////
func CreateServer():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	PlayerConnected = 1
	
	addPlayer.rpc(multiplayer.get_unique_id())
	GameStart.emit()
	GameStarted = true

func JoinServer():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)	
	multiplayer.multiplayer_peer = peer

# ///////////////// SIGNALS /////////////////

func _player_connected(id:int):
	print("MULTIPLAYER::NEW_PLAYER_CONNECTED: ", id)
	if multiplayer.is_server():
		addPlayer.rpc(id)
		for player in PlayersNode.get_children():
			addPlayer.rpc_id(id, int(str(player.name)))
	
	PlayerConnected += 1
	GameStart.emit()
	GameStarted = true

func _player_disconnected(id):
	print("MULTIPLAYER::PLAYER_LEFT: ", id)
	PlayerConnected -= 1
	RemovePlayer.rpc(id)
	
# ///////////////// CALLS /////////////////
@rpc("any_peer", "call_local")
func addPlayer(id):
	if id == multiplayer.get_unique_id() and PlayersNode.has_node(str(id)):
		return

	var player = PlayerScene.instantiate()
	var spawn_area = Rect2(Vector2(100, 100), Vector2(500, 500))
	var spawn_position = Vector2(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	)
	
	player.name = str(id)
	player.position = spawn_position
	PlayersNode.add_child(player)
	
	print("MULTIPLAYER::ADD_PLAYER_ID: ", id)

@rpc("any_peer", "call_local")
func RemovePlayer(id):
	var player = PlayersNode.get_node_or_null(str(id))
	if player:
		player.queue_free()
		print("MULTIPLAYER::PLAYER_REMOVED_ID: ", id)
