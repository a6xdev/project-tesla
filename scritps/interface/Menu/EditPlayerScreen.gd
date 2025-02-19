extends Control

@onready var name_input: TextEdit = $CenterContainer/VBoxContainer/name/TextEdit
@onready var gender_dropdown: OptionButton = $CenterContainer/VBoxContainer/gender/OptionButton

func _ready():
	name_input.text = PlayerData.player_name
	gender_dropdown.selected = PlayerData.player_gender

func _on_save_pressed():
	PlayerData.player_name = name_input.text
	PlayerData.player_gender = PlayerData.gender.MALE if gender_dropdown.selected == 0 else PlayerData.gender.FEMALE
	PlayerData.save_data()
