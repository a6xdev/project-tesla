extends CanvasLayer

@onready var lobby_screen: Control = $LobbyScreen
@onready var game_menu: Control = $GameMenu
@onready var edit_player_screen: Control = $EditPlayerScreen
@onready var text_edit: TextEdit = $EditPlayerScreen/CenterContainer/VBoxContainer/name/TextEdit

@export var LobbyManagerNode:LobbyManager

func _ready() -> void:
	lobby_screen.hide()
	edit_player_screen.hide()
	game_menu.show()
	
	LobbyManagerNode.GameStart.connect(GameStarted)

# Game Menu
func _on_play_pressed() -> void:
	game_menu.hide()
	lobby_screen.show()
	edit_player_screen.hide()

func _on_EditPlayer_pressed() -> void:
	game_menu.hide()
	lobby_screen.hide()
	edit_player_screen.show()

# EditPlayerScreen
func _on_exit_pressed() -> void:
	lobby_screen.hide()
	edit_player_screen.hide()
	game_menu.show()

func GameStarted():
	$LobbyScreen.hide()
	hide()
