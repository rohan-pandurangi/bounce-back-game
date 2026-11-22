extends Node2D

@onready var player = $player
@onready var main_camera = $mainCamera
@onready var world_reset = $worldReset

var respawn_pending: bool = false


func _ready() -> void:
	player.died.connect(_on_player_died)
	player.camera_remote_transform.remote_path = main_camera.get_path()
	world_reset.reset_world(player)


func _on_player_died() -> void:
	if respawn_pending:
		return

	respawn_pending = true
	print("Game over. Resetting world in 3 seconds.")
	get_tree().create_timer(3.0).timeout.connect(_respawn)


func _respawn() -> void:
	world_reset.reset_world(player)
	respawn_pending = false
