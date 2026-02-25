extends CharacterBody2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var mvmt_timer = $Timers/MovementTimer
@onready var shoot_timer = $Timers/ShootTimer
@onready var bullet_markers = $BulletMarkers

var bullet = preload("res://scenes/playerbullet.tscn")

const SPEED = 300.0
var last_direction = 0
var health = 100
var canShoot = true

# The functions are arranged as follows:
# 1. Movement-related
# 2. Collision-related
# 3. Firing-related
# 4. Timer-related

# Movement-related Functions

func _physics_process(_delta: float) -> void:
	var movement = Vector2.ZERO
	
	if Input.is_action_pressed("Up"):
		movement.y = -1
	if Input.is_action_pressed("Down"):
		movement.y = 1
	if Input.is_action_pressed("Left"):
		movement.x = -1
	if Input.is_action_pressed("Right"):
		movement.x = 1
		
	movement = movement.normalized() * SPEED
	velocity = movement
	move_and_slide()
	
	global_position.x = clamp(global_position.x, 35, 665)
	global_position.y = clamp(global_position.y, 40, 765)
	
	if movement.x < 0:
		if last_direction != -1:
			anim_sprite.play("strafe_left")
			mvmt_timer.start()
			last_direction = -1
		
	elif movement.x > 0:
		if last_direction != 1:
			anim_sprite.play("strafe_right")
			mvmt_timer.start()
			last_direction = 1
		
	else:
		if last_direction == -1:
			anim_sprite.play("straighten_from_left")
		elif last_direction == 1:
			anim_sprite.play("straighten_from_right")
		else: anim_sprite.play("straight")
		last_direction = 0

# Collision-related Functions

func take_damage(damage: int) -> void:
	health -= damage
	is_health_zero()

func is_health_zero() -> void:
	if health == 0:
		explode()
		shoot_timer.stop()
		canShoot = false

func explode() -> void:
	anim_sprite.play("explode")
	await anim_sprite.animation_finished
	queue_free()

# Firing-related Functions

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Fire") and canShoot:
		shoot()
	
func _on_ShootTimer_timeout():
	canShoot = true
	
func shoot():
	for marker in bullet_markers.get_children():
		var bullet_item = bullet.instantiate()
		bullet_item.global_position = marker.global_position
		get_parent().add_child(bullet_item)
		canShoot = false
		shoot_timer.start()

# Timer-related Functions

func _on_MovementTimer_timeout() -> void:
	if anim_sprite.animation == "full_left":
		anim_sprite.play("strafe_left")
	elif anim_sprite.animation != "full_right":
		anim_sprite.play("strafe_right")
		
func _on_movement_animation_finished(anim_name: String) -> void:
	if anim_name == "straighten_from_left" or anim_name == "straighten_from_right":
		anim_sprite.play("straight")
