extends TextureProgressBar

@onready var player = get_tree().get_first_node_in_group("player")


func update():
	value = player.player_health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.healthChanged.connect(update)
	update() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
