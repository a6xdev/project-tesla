extends CharacterBody2D

@onready var camera: Camera2D = $camera
@onready var player_enter: Timer = $PlayerTimer

@export_group("Object Settings")
@export var steering_angle = 15  # Maximum angle for steering the car's wheels
@export var engine_power = 900  # How much force the engine can apply for acceleration
@export var friction = -55  # The friction coefficient that slows down the car
@export var drag = -0.06  # Air drag coefficient that also slows down the car
@export var braking = -450  # Braking power when the brake input is applied
@export var max_speed_reverse = 250  # Maximum speed limit in reverse
@export var slip_speed = 400  # Speed above which the car's traction decreases (for drifting)
@export var traction_fast = 2.5  # Traction factor when the car is moving fast (affects control)
@export var traction_slow = 10  # Traction factor when the car is moving slow (affects control)

@export_group("Weapons")
@export var bullet:PackedScene
@export var muzzle:Marker2D

var wheel_base = 65  # Distance between the front and back axle of the car
var acceleration = Vector2.ZERO  # Current acceleration vector
var steer_direction  # Current direction of steering

var driver
var active:bool = false
var is_attacking:bool = false
var in_vehicle = true

func _input(event: InputEvent) -> void:
	if active:
		if Input.is_action_just_pressed("a_interact") and driver:
			rpc("exit_vehicle")
			
		if Input.is_action_just_pressed("a_shoot"):
			var mouse_position = get_global_mouse_position()
			var bullet_direction = (mouse_position - global_position).normalized()
			rpc("shoot", bullet_direction)

func _physics_process(delta):
	if active:
		if driver and driver.is_multiplayer_authority():
			camera.enabled = true
			acceleration = Vector2.ZERO
			get_input()
			calculate_steering(delta)
		else:
			camera.enabled = false

		velocity += acceleration * delta
		apply_friction(delta)
		move_and_slide()
	else:
		camera.enabled = false
		
	if is_multiplayer_authority():
		rpc("sync_vehicle_state", global_position, rotation, velocity)

@rpc("any_peer", "call_local")
func sync_vehicle_state(position: Vector2, rotation: float, velocity: Vector2):
	global_position = position
	rotation = rotation
	self.velocity = velocity

#function to handle input from the user and apply effects to the car's movement
func get_input():
	if driver and driver.is_multiplayer_authority():
		var turn = Input.get_axis("m_left", "m_right")
		steer_direction = turn * deg_to_rad(steering_angle)

		if Input.is_action_pressed("m_forward"):
			acceleration = transform.x * engine_power

		if Input.is_action_pressed("m_backward"):
			acceleration = transform.x * braking

#Function to apply friction forces to the car, making it 'slide' to a halt
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
	
# Function to calculate the steering effect
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)

	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast

	var d = new_heading.dot(velocity.normalized())

	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)

	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	rotation = new_heading.angle()

@rpc("call_local", "any_peer")
func shoot(bullet_direction: Vector2):
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = muzzle.global_transform.origin
	bullet_instance.direction = bullet_direction
	bullet_instance.in_vehicle = true
	bullet_instance.shooter = self
	get_parent().add_child(bullet_instance)

func levels_system(amount: int):
	if multiplayer.is_server() or multiplayer.get_unique_id() == get_multiplayer_authority():
		driver.levels_system(amount)

func enter_vehicle(player):
	if not driver:
		set_multiplayer_authority(player.get_multiplayer_authority())
		player_enter.start()
		driver = player

@rpc("any_peer", "call_local")
func exit_vehicle():
	if driver and active:
		var player = driver
		player.global_position = global_position + Vector2(30, 0)
		player.setInVehicle.rpc(false)
		driver = null
		active = false

func _PlayerEnter_timeout() -> void:
	active = true
