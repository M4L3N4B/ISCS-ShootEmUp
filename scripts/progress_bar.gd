extends ProgressBar

@export var player: CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.healthChanged.connect(update)
	update() # Replace with function body.

func update():
	value = player.health
