extends Node2D

@onready var player = $player
@onready var main_camera = $mainCamera
@onready var world_reset = $worldReset
@onready var spawner = $spawner
@onready var kill_label: Label = $CanvasLayer/KillCountLabel

var respawn_pending: bool = false

var killCount: int = 0
var bossCount: int = 1
var boss_triggered: bool = false
@onready var boss_label: Label = $CanvasLayer/BossCountLabel
@onready var game_over_label: Label = $CanvasLayer/GameOverLabel
@onready var game_over_bg: Sprite2D = $CanvasLayer/GameOverScreen
var respawn_seconds_left: float = 0.0


func _ready() -> void:
	player.died.connect(_on_player_died)
	player.camera_remote_transform.remote_path = main_camera.get_path()
	world_reset.reset_world(player)
	_update_kill_label()
	game_over_label.hide()
	game_over_bg.hide()


func _process(delta: float) -> void:
	if not respawn_pending:
		return
	respawn_seconds_left = maxf(0.0, respawn_seconds_left - delta)
	game_over_label.text = "%d" % ceili(respawn_seconds_left)
	if respawn_seconds_left <= 0.0:
		_respawn()


func register_kill() -> void:
	killCount += 1
	_update_kill_label()
	if killCount >= 30 and not boss_triggered:
		boss_triggered = true
		killCount = 0
		_update_kill_label()
		spawner.start_boss_fight()


func _update_kill_label() -> void:
	if is_instance_valid(kill_label):
		kill_label.text = "%d / 30" % killCount
	if is_instance_valid(boss_label):
		boss_label.text = "%d" % bossCount


func register_boss_kill() -> void:
	if not boss_triggered:
		return

	bossCount += 1
	boss_triggered = false
	killCount = 0
	_update_kill_label()

	spawner.halve_spawn_interval()

	spawner.halve_spawn_interval()
	world_reset.reset_world(player)
	spawner.reset_spawning()

func _on_player_died() -> void:
	if respawn_pending:
		return

	world_reset.clear_projectiles()

	respawn_pending = true
	respawn_seconds_left = 3.0
	game_over_label.text = "3"
	game_over_label.show()
	game_over_bg.show()
	print("Game over. Respawning in 3 seconds.")


func _respawn() -> void:
	world_reset.reset_world(player)
	killCount = 0
	boss_triggered = false
	_update_kill_label()
	spawner.reset_spawning()
	respawn_pending = false
	game_over_label.hide()
	game_over_bg.hide()
	respawn_seconds_left = 0.0
