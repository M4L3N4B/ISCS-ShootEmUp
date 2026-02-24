extends Area2D


@onready var anim_sprite = $AnimatedSprite2D
@onready var mvmt_timer = $Timers/MovementTimer
@onready var shoot_timer = $Timers/ShootTimer
@onready var bullet_markers = $BulletMarkers

@export var bullet: PackedScene
@export var health := 50
@export var margin_length := 25
@export var speeds := Vector2(75, 100)

# Durations in seconds
const mvmt_types := ["strafe_left", "strafe_right", "advance"]
@export var mvmt_durations := {
	"aim": 5,
	"strafe_left": 1,
	"strafe_right": 1,
	"advance": 1
}
var current_motion := "aim"
var destroyed := false


# border_margins sets the bounds where an enemy can move freely
# (enemy moves towards margins if out of bounds)
var border_margins: Dictionary


func _ready() -> void:
	var sprite_size = anim_sprite.sprite_frames.get_frame_texture("straight", 0).get_size() * scale
	var true_margin_lengths = Vector2(margin_length, margin_length) + sprite_size/2
	
	# Top is randomized so that enemies settle in different spots
	border_margins = {
		"top": true_margin_lengths.y * randi_range(1, 3),
		"left": true_margin_lengths.x,
		"right": get_viewport().size.x - true_margin_lengths.y,
		"bottom": get_viewport().size.y + sprite_size.y
	}
	
	anim_sprite.play("straight")
	set_timers()


func is_within_bounds() -> bool:
	return border_margins["left"] < position.x and \
		position.x < border_margins["right"] and \
		border_margins["top"] < position.y


# Enemy moves and shoots randomly (unless it's out of bounds)
func _process(delta: float) -> void:
	if destroyed:
		return
		
	if health <= 0:
		destroyed = true
		explode()
		
	if position.y > border_margins["bottom"]:
		queue_free()
	
	if is_within_bounds():
		move(delta)
	else:
		move_to_screen(delta)
	

# Functions are ordered like this:
# 1. Movement-Related
# 2. Collision-Related
# 3. Timer-Related


# ==== Movement-Related  ====

func move(delta: float) -> void:
	match current_motion:
		"strafe_left":
			strafe(-1, delta)
		"strafe_right":
			strafe(1, delta)
		"advance":
			advance(delta)


# First moves towards side margins, and then towards top margin
func move_to_screen(delta: float) -> void:
	if position.x < border_margins["left"]:
		strafe(1, delta)
	elif border_margins["right"] < position.x:
		strafe(-1, delta)
	elif position.y < border_margins["top"]:
		advance(delta)


func strafe(direction: int, delta: float) -> void:
	match direction:
		-1 : position.x -= speeds.x * delta
		1  : position.x += speeds.x * delta
		

func advance(delta) -> void:
	position.y += speeds.y * delta


func animate(motion: String) -> void:
	if anim_sprite.animation == "strafe_left" or anim_sprite.animation == "full_left":
		match motion:
			"strafe_left" : anim_sprite.play("full_left")
			"strafe_right" : anim_sprite.play("strafe_right")
			"aim", "advance" : anim_sprite.play("straighten_from_left")
	
	elif anim_sprite.animation == "strafe_right" or anim_sprite.animation == "full_right":
		match motion:
			"strafe_left" : anim_sprite.play("strafe_left")
			"strafe_right" : anim_sprite.play("full_right")
			"aim", "advance" : anim_sprite.play("straighten_from_right")
	
	elif anim_sprite.animation in ["straighten_from_right", "straighten_from_left", "straight"]:
		match motion:
			"strafe_left" : anim_sprite.play("strafe_left")
			"strafe_right" : anim_sprite.play("strafe_right")
		


#  ==== Collision-Related ====

func shoot() -> void:
	for marker in bullet_markers.get_children():
		var bullet_item = bullet.instantiate()
		bullet_item.global_position = marker.global_position
		get_parent().add_child(bullet_item)


func take_damage(damage: int) -> void:
	health -= damage

func explode() -> void:
	anim_sprite.play("explode")
	await anim_sprite.animation_finished
	queue_free()



# ==== Timer-Related ====

func set_timers() -> void:
	mvmt_timer.start(mvmt_durations[current_motion])
	
	if current_motion == "aim":
		shoot_timer.start(mvmt_durations["aim"] / 2.0)	


func _on_shoot_timer_timeout() -> void:
	shoot()


# Alternates between aiming and moving
func _on_movement_timer_timeout() -> void:
	if current_motion in mvmt_types:
		current_motion = "aim"
	else:
		current_motion = mvmt_types.pick_random()
	animate(current_motion)
	
	set_timers()
