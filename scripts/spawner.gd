
extends Node2D

@onready var enemy_scene = preload("res://scenes/enemy.tscn")

@export var spawn_margin: float = 50.0

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func _on_timer_timeout() -> void:
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
