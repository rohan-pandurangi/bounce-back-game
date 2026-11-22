extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float

var speed: float = 2000.0
var collision_count: int = 0

const MAX_COLLISIONS: int = 3

func _ready() -> void:
	global_position = pos
	global_rotation = rota

	velocity = Vector2(speed, 0).rotated(dir)


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)

	if collision:
		var body = collision.get_collider()

		if body is enemy:
			body.queue_free()
			queue_free()
			return

		collision_count += 1

		if collision_count >= MAX_COLLISIONS:
			queue_free()
			return

		velocity = velocity.bounce(collision.get_normal())
