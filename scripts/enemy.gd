
extends CharacterBody2D

class_name enemy

var Player: player = null

var speed: float = 100.0
var health: int = 3

var direction: Vector2 = Vector2.ZERO

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_strength: float = 900.0
var knockback_friction: float = 1500.0

var invincibility_timer: float = 0.0
const INVINCIBILITY_DURATION: float = 0.3

var flash_timer: float = 0.0
var flash_visible: bool = false
const FLASH_INTERVAL: float = 0.05


func _ready() -> void:
	print(name, " health: ", health)


func _process(_delta: float) -> void:
	if Player != null and not Player.is_dead:
		look_at(Player.global_position)


func _physics_process(delta: float) -> void:

	if invincibility_timer > 0.0:
		invincibility_timer -= delta
		flash_timer += delta

		if flash_timer >= FLASH_INTERVAL:
			flash_timer = 0.0
			flash_visible = not flash_visible

			modulate.a = 0.25 if flash_visible else 1.0

		if invincibility_timer <= 0.0:
			invincibility_timer = 0.0
			modulate.a = 1.0
			flash_visible = false

	if Player != null and not Player.is_dead:
		var enemy_to_player = Player.global_position - global_position

		if enemy_to_player.length() > 20.0:
			direction = enemy_to_player.normalized()
		else:
			direction = Vector2.ZERO
	else:
		direction = Vector2.ZERO

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_friction * delta
	)

	velocity = direction * speed + knockback_velocity
	move_and_slide()


func take_damage(amount: int = 1, hit_position: Vector2 = Vector2.ZERO) -> void:

	if invincibility_timer > 0.0:
		return

	health -= amount
	print(name, " health: ", health)

	var knockback_direction = global_position - hit_position

	if hit_position == Vector2.ZERO or knockback_direction.length_squared() < 0.001:
		knockback_direction = -direction

	if knockback_direction.length_squared() > 0.001:
		knockback_direction = knockback_direction.normalized()
	else:
		knockback_direction = Vector2.RIGHT

	knockback_velocity = knockback_direction * knockback_strength

	invincibility_timer = INVINCIBILITY_DURATION
	flash_timer = 0.0
	flash_visible = true
	modulate.a = 0.25

	if health <= 0:
		print(name, " defeated")
		queue_free()


func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is player:
		if Player == null:
			Player = body
			print(name, " found player")


func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is player:
		if Player != null:
			Player = null
			print(name, " lost player")
