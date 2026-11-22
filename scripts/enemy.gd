extends CharacterBody2D

class_name enemy

var Player: player = null

@export var speed: float = 100.0
@export var health: int = 3
@export var is_boss: bool = false
var defeat_reported: bool = false

const BOSS_SHOT_SCENE: PackedScene = preload("res://scenes/boss_attack_shot.tscn")
@export var boss_shot_interval_seconds: float = 0.1
@export var boss_shot_angle_step_degrees: float = 20.0
@export var boss_shot_speed: float = 350.0
var boss_shot_angle_offset_degrees: float = 0.0

var direction: Vector2 = Vector2.ZERO

var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 900.0
var knockback_friction: float = 1500.0

var invincibility_timer: float = 0.0
const INVINCIBILITY_DURATION: float = 0.3

var flash_timer: float = 0.0
var flash_visible: bool = false
const FLASH_INTERVAL: float = 0.05


func _ready() -> void:
	print(name, " health: ", health)
	if is_boss:
		_boss_spiral_loop()


func _boss_spiral_loop() -> void:
	while is_inside_tree() and is_boss and health > 0:
		_fire_boss_shot()
		await get_tree().create_timer(maxf(0.05, boss_shot_interval_seconds)).timeout
		if not is_inside_tree() or health <= 0:
			return
		boss_shot_angle_offset_degrees += boss_shot_angle_step_degrees


func _fire_boss_shot() -> void:
	var shot_direction := Vector2.RIGHT
	if Player != null and is_instance_valid(Player):
		shot_direction = (Player.global_position - global_position).normalized()
	if shot_direction.length_squared() < 0.001:
		shot_direction = Vector2.RIGHT

	shot_direction = shot_direction.rotated(deg_to_rad(boss_shot_angle_offset_degrees))
	var shot := BOSS_SHOT_SCENE.instantiate() as boss_attack_shot
	shot.direction = shot_direction
	shot.speed = boss_shot_speed
	get_tree().current_scene.add_child(shot)
	shot.global_position = global_position


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

	if health <= 0 and not defeat_reported:
		defeat_reported = true
		print(name, " defeated")
		var world = get_tree().current_scene
		if world != null:
			if is_boss and world.has_method("register_boss_kill"):
				world.register_boss_kill()
			elif not is_boss and world.has_method("register_kill"):
				world.register_kill()
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
