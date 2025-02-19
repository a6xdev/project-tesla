extends CharacterBody2D
class_name Player

# =========================================================
# ONREADY
# =========================================================

@onready var sprite: AnimatedSprite2D = $sprite
@onready var collision: CollisionShape2D = $collision
@onready var camera: Camera2D = $camera

# Interface
@onready var MainInterface: CanvasLayer = $Interface
@onready var InventoryNode: Inventory = $Interface/Inventory
@onready var health: Label = $PlayerUI/VBoxContainer/health
@onready var level: Label = $PlayerUI/VBoxContainer/level
@onready var respawn_screen: Control = $Interface/RespawnScreen

# Areas
@onready var interaction_area: Area2D = $InteractionArea
@onready var attack_area: Area2D = $AttackArea

# =========================================================
# BASE
# =========================================================

@export_group("General Settings")
@export var MaxHealth:int = 100
@export_subgroup("Profile Settings")
@export var PlayerName:String = "Default Name"

@export_group("Behavior Settings")
@export var CanMoveCamera:bool = true ## Camera Movement
@export var CanMove:bool = true ## Player Movement
@export var CanAttack:bool = true
@export var CanInteract:bool = true
@export var CanShoot:bool = false

@export_group("Movement Settings")
@export var MoveSpeed:int = 550

var GenderChosen = PlayerData.player_gender

# IFs
var IsAttacking:bool = false
var IsInVehicle:bool = false
var IsDead:bool = false
var InInventory:bool = false

# Experience
var XP_TO_NEXT_LEVEL:int = 100
var CurrentXP:int = 0
var CurrentLevel:int = 0

# Vehicle System
var Vehicle = null
var CurrentVehicle:CharacterBody2D = null

# Melee Attack
var MeleeDamage:int = 15
var AttackDuration:float = 0.5

# Others
var CurrentHealth:int = 100
var DeathCount:int = 0
var HeldItem
var RespawnTarget = Vector2.ZERO

# =========================================================
# GODOT FUNCTIONS
# =========================================================

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		rpc("MeleeAttack", false)
		camera.enabled = true

func _input(_event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("a_interact") and Vehicle:
			if not IsInVehicle:
				CurrentVehicle = Vehicle
				CurrentVehicle.enter_vehicle(self)
				camera.enabled = false
				rpc("setInVehicle", true)

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		if not IsDead:
			if not IsInVehicle:
				collision.disabled = false
				camera.enabled = true
				show()
			else:
				collision.disabled = true
				camera.enabled = false
				hide()
			
			InterfaceController()
			MovementController()
			AttackController()
			#DEBUG()
			
			PlayerCustomization()
			InteractSystem()
		else:
			collision.disabled = true
			respawn_screen.show()
			hide()
			
			#collision.disabled = !IsInVehicle
			#camera.enabled = !IsInVehicle

# =========================================================
# CONTROLLERS
# =========================================================
func InterfaceController() -> void:
	InInventory = InventoryNode.visible
	health.text = str(CurrentHealth)
	level.text = str(CurrentLevel)

func MovementController():
	if not InInventory and CanMove:
		var mouse_position = get_global_mouse_position()
		velocity = Input.get_vector("m_left", "m_right", "m_forward", "m_backward") * MoveSpeed
		look_at(mouse_position)
	
		move_and_slide()

func AttackController():
	if Input.is_action_just_pressed("a_meleeAttack"):
		rpc("MeleeAttack", true)
		IsAttacking = true
		await get_tree().create_timer(AttackDuration).timeout
		rpc("MeleeAttack", false)
		IsAttacking = false
		
# =========================================================
# MECHANICS
# =========================================================
func PlayerCustomization():
	#name_label.text = PlayerName
		
	match GenderChosen:
		PlayerData.gender.MALE:
			sprite.modulate = Color(0.13, 0.239, 1)
		PlayerData.gender.FEMALE:
			sprite.modulate = Color(0.837, 0.13, 1)

func SetDamage(damage:int) -> void:
	if multiplayer.is_server() or multiplayer.get_unique_id() == get_multiplayer_authority():
		CurrentHealth -= damage
		
		if CurrentHealth <= 0:
			IsDead = true
			DeathCount += 1

func ExperienceSystem(XP:int) -> void:
	if multiplayer.is_server() or multiplayer.get_unique_id() == get_multiplayer_authority():
		CurrentXP += XP 
		if CurrentXP >= XP_TO_NEXT_LEVEL:
			CurrentLevel += 1
			CurrentXP = 0

func InteractSystem():
	if Input.is_action_just_pressed("a_interact") and HeldItem:
		HeldItem.rpc("collect", self)
		HeldItem = null

func InventoryAddItem(item: Item) -> bool:
	for slot in $Interface/Inventory/InventoryGrid.get_children():
		if slot.texture_rect.texture == null:
			var item_data = {
				"ITEM_NAME": item.item_name,
				"ITEM_TYPE": item.item_type,
				"SLOT_TYPE": item.slot_type,
				"AMOUNT": item.amount,
				"STATS": item.stats,
				"TEXTURE": item.texture.texture
			}
			slot.set_item(item_data)  # Updates the slot with the item data
			return true  # Item added successfully
	return false  # Inventory full, item not added

@rpc("any_peer", "call_local")
func MeleeAttack(value:bool):
	attack_area.monitoring = value

@rpc("any_peer", "call_local")
func RespawnPlayer():
	respawn_screen.hide()
	CurrentHealth = MaxHealth
	global_transform.origin = RespawnTarget
	IsDead = false

@rpc("any_peer", "call_local")
func setInVehicle(state: bool):
	IsInVehicle = state


# =========================================================
# OTHERS
# =========================================================

func DEBUG() -> void:
	$MainInterface/Label.text = str(IsInVehicle)
	if CurrentVehicle:
		print("Vehicle: ", Vehicle)
		print("IsInVehicle: ", IsInVehicle)
		print("CurrentVehicle: ", CurrentVehicle)
	pass

# =========================================================
# SIGNALS
# =========================================================

# => InteractionArea: Just for Area2D type nodes
func _InteractionArea_entered(body: Area2D) -> void:
	if body is Item:
		HeldItem = body
func _InteractionArea_exited(body: Area2D) -> void:
	if body is Item:
		HeldItem = null
func _interactionBody_entered(body: Node2D) -> void:
	if body.is_in_group("GroupVehicle"):
		Vehicle = body
func _interactionBody_exited(body: Node2D) -> void:
	if body.is_in_group("GroupVehicle"):
		Vehicle = null

# => MeleeAttack
#func _attackAreaBody_entered(body: Node2D) -> void:
	#if body is Enemy or body is Player:
		#body.SetDamage(MeleeDamage)
