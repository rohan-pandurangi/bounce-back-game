extends CharacterBody2D
class_name enemy

var Player: player = null

var speed: float =  100.0
var direction := Vector2.ZERO

func _process(delta: float) -> void:
	if Player != null:
				look_at(Player.global_position)

func _physics_process(delta: float) -> void:
	if Player != null:
		var enemy_to_player = Player.global_position - global_position

		if enemy_to_player.length() > 20:
			direction = enemy_to_player.normalized()
		else:
			direction = Vector2.ZERO
	else:
		direction = Vector2.ZERO

	velocity = direction * speed
	move_and_slide()
	
func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is  player:
		if Player  == null:
			Player  =  body
			print(name +  "found player") # Replace with function body.

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is  player:
		if Player  != null:
			Player  =  null
			print(name +  "lost player")  # Replace with function body.
