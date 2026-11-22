extends CharacterBody2D
class_name boss_attack_shot

@export var speed: float = 350.0
@export var damage: int = 1
@export var max_bounces: int = 1

var direction: Vector2 = Vector2.RIGHT
var bounce_count: int = 0


func _ready() -> void:
	velocity = direction.normalized() * speed


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision == null:
		return

	var body := collision.get_collider()
	if body is player:
		body.take_damage(self)
		queue_free()
		return

	bounce_count += 1
	if bounce_count > max_bounces:
		queue_free()
		return

	velocity = velocity.bounce(collision.get_normal())
