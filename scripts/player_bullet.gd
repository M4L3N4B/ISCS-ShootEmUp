# Source: https://www.youtube.com/watch?v=7GLBk9d-tLk

extends Area2D

@onready var anim_sprite = $AnimatedSprite2D
const SPEED = 200
var top_border: float

func _physics_process(delta: float):
	top_border = 0
	position.y -= delta * SPEED
	anim_sprite.play("fire")
	if position.y < top_border:
		queue_free()
