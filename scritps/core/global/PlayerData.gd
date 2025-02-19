extends Node

const SAVE_PATH = "user://player_data.json"

enum gender { MALE, FEMALE }

var player_name: String = "Jogador"
var player_gender: gender = gender.MALE

func _ready() -> void:
	ensure_data_exists()
	load_data()

func save_data():
	var data = {
		"player_name": player_name,
		"player_gender": player_gender
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func ensure_data_exists():
	if not FileAccess.file_exists(SAVE_PATH):
		save_data()

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		file.close()
		if json:
			player_name = json.get("player_name", "Player")
			player_gender = gender.get(json.get("player_gender", 0), gender.MALE)
