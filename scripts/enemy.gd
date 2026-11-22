extends CharacterBody2D

class_name enemy

var Player: player = null

var speed: float = 100.0

var health: int = 3

var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	print(name, " health: ", health)


func _process(_delta: float) -> void:
	if Player != null and not Player.is_dead:
		look_at(Player.global_position)


func _physics_process(_delta: float) -> void:
	if Player != null and not Player.is_dead:
		var enemy_to_player = Player.global_position - global_position

		if enemy_to_player.length() > 20.0:
			direction = enemy_to_player.normalized()
		else:
			direction = Vector2.ZERO
	else:
		direction = Vector2.ZERO

	velocity = direction * speed
	move_and_slide()


func take_damage(amount: int = 1) -> void:
	health -= amount
	print(name, " health: ", health)

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
