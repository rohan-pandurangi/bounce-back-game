extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float
var dmg: int = 1

var speed: float = 750.0
var bounce_count: int = 0


const MAX_BOUNCES: int = 3


func _ready() -> void:
	global_position = pos
	global_rotation = rota
	velocity = Vector2(speed, 0.0).rotated(dir)


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)

	if collision == null:
		return

	var body = collision.get_collider()

	if body is enemy:
		body.take_damage(dmg)
	

	if body is player:
		queue_free()
		return

	bounce_count += 1
	if bounce_count > MAX_BOUNCES:
		queue_free()
		return

	velocity = velocity.bounce(collision.get_normal())
