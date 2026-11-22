
extends Node2D

@onready var enemy_scene = preload("res://scenes/enemy.tscn")
@onready var boss_scene = preload("res://scenes/boss.tscn")
@onready var spawn_timer: Timer = $Timer

var boss_started: bool = false

@export var spawn_margin: float = 50.0

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	spawn_timer.wait_time = 2.0


func _on_timer_timeout() -> void:
	if not boss_started:
		spawn_enemy()


func spawn_enemy() -> void:
	var camera = get_viewport().get_camera_2d()

	if camera == null:
		push_warning("No active Camera2D found!")
		return

	var viewport_size = get_viewport_rect().size
	var half_size = viewport_size / (2.0 * camera.zoom)

	var camera_center = camera.get_screen_center_position()

	var spawn_position = Vector2.ZERO

	var side = rng.randi_range(0, 3)

	match side:
		0: # Top
			spawn_position.x = rng.randf_range(
				camera_center.x - half_size.x,
				camera_center.x + half_size.x
			)
			spawn_position.y = camera_center.y - half_size.y - spawn_margin

		1: # Bottom
			spawn_position.x = rng.randf_range(
				camera_center.x - half_size.x,
				camera_center.x + half_size.x
			)
			spawn_position.y = camera_center.y + half_size.y + spawn_margin

		2: # Left
			spawn_position.x = camera_center.x - half_size.x - spawn_margin
			spawn_position.y = rng.randf_range(
				camera_center.y - half_size.y,
				camera_center.y + half_size.y
			)

		3: # Right
			spawn_position.x = camera_center.x + half_size.x + spawn_margin
			spawn_position.y = rng.randf_range(
				camera_center.y - half_size.y,
				camera_center.y + half_size.y
			)

	var ene = enemy_scene.instantiate()
	ene.add_to_group("enemies")

	get_parent().add_child(ene)

	ene.global_position = spawn_position


func start_boss_fight() -> void:
	if boss_started:
		return
	boss_started = true
	spawn_timer.stop()

	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy_node):
			enemy_node.queue_free()

	var boss = boss_scene.instantiate()
	boss.add_to_group("enemies")
	get_parent().add_child(boss)

	var player_node = get_tree().get_first_node_in_group("player")
	if player_node != null:
		boss.global_position = player_node.global_position + Vector2(450, 0)
	else:
		boss.global_position = Vector2(1091, 363)


func reset_spawning() -> void:
	boss_started = false
	spawn_timer.start()


func halve_spawn_interval() -> void:
	spawn_timer.wait_time *=0.75
