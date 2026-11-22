extends CharacterBody2D

class_name player

signal died

@onready var camera_remote_transform: RemoteTransform2D = $cameraRemoteTransform
@onready var player_sprite: Sprite2D = $body
@onready var hitbox: Area2D = $hitbox

var speed: float = 400.0

var player_health: int = 3

var invulnerability_time: float = 0.0
const INVULNERABILITY_DURATION: float = 1.0
const KNOCKBACK_STRENGTH: float = 650.0
const KNOCKBACK_FRICTION: float = 1800.0

var knockback_velocity: Vector2 = Vector2.ZERO
var is_dead: bool = false

@export var background_size: Vector2 = Vector2(3901.5, 2270.5)
@export var background_position: Vector2 = Vector2(641, 363)

var bullet_path = preload("res://scenes/ball.tscn")


func _ready() -> void:
	print("Player health: ", player_health)


func _process(_delta: float) -> void:
	if is_dead:
		return

	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("shoot"):
		fire()

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	_update_invulnerability(delta)

	var move_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	var movement_velocity = Vector2.ZERO
	if move_dir != Vector2.ZERO:
		movement_velocity = speed * move_dir.normalized()

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		KNOCKBACK_FRICTION * delta
	)
	velocity = movement_velocity + knockback_velocity
	move_and_slide()


	for body in hitbox.get_overlapping_bodies():
		if body is enemy:
			take_damage(body)
			break

	var half_size = background_size / 2.0
	global_position.x = clamp(
		global_position.x,
		background_position.x - half_size.x,
		background_position.x + half_size.x
	)
	global_position.y = clamp(
		global_position.y,
		background_position.y - half_size.y,
		background_position.y + half_size.y
	)


func _update_invulnerability(delta: float) -> void:
	if invulnerability_time > 0.0:
		invulnerability_time = maxf(0.0, invulnerability_time - delta)

		if invulnerability_time > 0.0:
			var flash_color: Color = player_sprite.modulate
			flash_color.a = 0.25 if int(invulnerability_time * 10.0) % 2 == 0 else 1.0
			player_sprite.modulate = flash_color
		else:
			var normal_color: Color = player_sprite.modulate
			normal_color.a = 1.0
			player_sprite.modulate = normal_color


func take_damage(source: Node2D) -> void:
	if is_dead or invulnerability_time > 0.0:
		return

	player_health -= 1
	print("Player health: ", player_health)

	var knockback_direction = global_position - source.global_position
	if knockback_direction.length_squared() < 0.001:
		knockback_direction = Vector2.RIGHT
	else:
		knockback_direction = knockback_direction.normalized()

	knockback_velocity = knockback_direction * KNOCKBACK_STRENGTH
	invulnerability_time = INVULNERABILITY_DURATION

	if player_health <= 0:
		is_dead = true
		velocity = Vector2.ZERO
		print("Player died. Respawning...")
		died.emit()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is enemy:
		take_damage(body)


func fire() -> void:
	var bullet = bullet_path.instantiate()
	bullet.dir = rotation
	bullet.pos = $firepos.global_position
	bullet.rota = global_rotation
	get_parent().add_child(bullet)
