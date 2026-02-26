extends Area2D


@onready var collider := $CollisionShape2D
@onready var anim_sprite := $AnimatedSprite2D
@export var speed := 200
const DAMAGE := 10
var bottom_border: float
var exploded := false

func _ready():
	collision_layer = 8
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	var height = anim_sprite.sprite_frames.get_frame_texture("flicker", 0).get_size().y * scale.y
	bottom_border = get_viewport().size.y + height
	anim_sprite.play("flicker")


func _process(delta: float):
	if exploded:
		return
	position.y += speed * delta
	if position.y > bottom_border:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if exploded:
		return
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)
	explode()


func explode():
	exploded = true
	anim_sprite.play("explode")
	collider.set_deferred("disabled", true)
	await anim_sprite.animation_finished
	queue_free()
