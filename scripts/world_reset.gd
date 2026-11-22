extends Node2D

@export var wall_count: int = 8
@export var arena_center: Vector2 = Vector2(641, 363)
@export var arena_half_size: Vector2 = Vector2(1850, 1020)
@export var safe_radius_from_center: float = 320.0
@export var wall_spacing: float = 220.0

const WALL_SCENE: PackedScene = preload("res://scenes/box.tscn")

var rng := RandomNumberGenerator.new()
var generated_walls: Array[Node2D] = []


func _ready() -> void:
	rng.randomize()

func clear_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()

func reset_world(target_player: Node2D) -> void:
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy_node):
			enemy_node.queue_free()

	for wall in generated_walls:
		if is_instance_valid(wall):
			wall.queue_free()
	generated_walls.clear()
	
	

	target_player.global_position = arena_center
	var player_node := target_player as player
	if player_node != null:
		player_node.velocity = Vector2.ZERO
		player_node.knockback_velocity = Vector2.ZERO
		player_node.player_health = 3
		player_node.is_dead = false
		player_node.invulnerability_time = 0.5

	_generate_walls()


func _generate_walls() -> void:
	var placed_positions: Array[Vector2] = []
	var attempts := 0
	var max_attempts := wall_count * 20

	while generated_walls.size() < wall_count and attempts < max_attempts:
		attempts += 1
		var candidate := Vector2(
			rng.randf_range(arena_center.x - arena_half_size.x, arena_center.x + arena_half_size.x),
			rng.randf_range(arena_center.y - arena_half_size.y, arena_center.y + arena_half_size.y)
		)

		if candidate.distance_to(arena_center) < safe_radius_from_center:
			continue

		var too_close := false
		for existing_position in placed_positions:
			if candidate.distance_to(existing_position) < wall_spacing:
				too_close = true
				break
		if too_close:
			continue

		var wall := WALL_SCENE.instantiate() as Node2D
		get_parent().add_child(wall)
		wall.global_position = candidate
		generated_walls.append(wall)
		placed_positions.append(candidate)
