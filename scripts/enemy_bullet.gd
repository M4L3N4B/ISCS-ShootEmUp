extends Area2D


@onready var collider := $CollisionShape2D
@onready var anim_sprite := $AnimatedSprite2D
@export var speed := 200
var bottom_border: float
var exploded := false

func _ready():
	var height = anim_sprite.sprite_frames.get_frame_texture("flicker", 0).get_size().y * scale.y
	bottom_border = get_viewport().size.y + height
	anim_sprite.play("flicker")


func _process(delta: float):
	if exploded:
		return
	position.y += speed * delta
	if position.y > bottom_border:
		queue_free()


func explode():
	anim_sprite.play("explode")
	collider.set_deferred("disabled", true)
	await anim_sprite.animation_finished
	queue_free()
