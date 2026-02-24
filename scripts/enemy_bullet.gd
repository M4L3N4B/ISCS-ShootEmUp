extends Area2D


@onready var anim_sprite = $AnimatedSprite2D
const speed = 200
var bottom_border: float


func _ready():
	var height = anim_sprite.sprite_frames.get_frame_texture("flicker", 0).get_size().y * scale.y
	bottom_border = get_viewport().size.y + height
	anim_sprite.play("flicker")


func _process(delta: float):
	position.y += speed * delta
	if position.y > bottom_border:
		queue_free()
