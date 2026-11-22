extends Node2D

@onready var player = $player
@onready var main_camera = $mainCamera

var respawn_pending: bool = false


func _ready() -> void:
	player.died.connect(_on_player_died)
	player.camera_remote_transform.remote_path = main_camera.get_path()


func _on_player_died() -> void:
	if respawn_pending:
		return

	respawn_pending = true
	print("Game over. Respawning in 3 seconds.")

	get_tree().create_timer(3.0).timeout.connect(_respawn)


func _respawn() -> void:
	get_tree().reload_current_scene()
