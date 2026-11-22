extends CharacterBody2D

class_name player
signal died

@onready var camera_remote_transform =  $cameraRemoteTransform

var speed = 400.0
@export var background_size = Vector2(3901.5, 2270.5)
@export var background_position = Vector2(641, 363)
var  bullet_path=preload("res://scenes/ball.tscn")

func _process(_delta: float) -> void:
	# look at mouse
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		fire()
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(_delta: float) -> void:

	var move_dir = Vector2(Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"))

	if move_dir != Vector2.ZERO:
		velocity = speed * move_dir.normalized()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()

	# Keep player inside background
	var half_size = background_size / 2

	global_position.x = clamp(
		global_position.x,
		background_position.x - half_size.x,
		background_position.x + half_size.x
	)

	global_position.y = clamp(
		global_position.y,
		background_position.y - half_size.y,
		background_position.y + half_size.y
	)
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is enemy:
		print("touched  the  player")
		died.emit()
		queue_free()
	 # Replace with function body.

func fire():
	var bullet=bullet_path.instantiate()
	bullet.dir=rotation
	bullet.pos=$firepos.global_position
	bullet.rota=global_rotation
	get_parent().add_child(bullet)
	
