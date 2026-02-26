extends Area2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var collider := $CollisionShape2D
const SPEED = 300
const DAMAGE = 25
var top_border: float
var hit := false

func _ready():
	collision_layer = 4
	collision_mask = 2
	area_entered.connect(_on_area_entered)
	anim_sprite.play("fire")

func _physics_process(delta: float):
	top_border = 0
	if hit:
		return
	position.y -= delta * SPEED
	if position.y < top_border:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if hit:
		return
	hit = true
	if area.has_method("take_damage"):
		area.take_damage(DAMAGE)
	explode()
	
func explode():
	anim_sprite.play("explode")
	collider.set_deferred("disabled", true)
	await anim_sprite.animation_finished
	queue_free()
