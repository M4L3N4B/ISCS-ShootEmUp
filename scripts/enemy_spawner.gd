extends Node

@export var enemy_scene: PackedScene
@export var spawn_interval := 3.0
@export var min_x := 50.0
@export var max_x := 650.0
@export var spawn_y := -60.0

@onready var spawn_timer := Timer.new()


func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()


func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(min_x, max_x), spawn_y)
	get_parent().add_child(enemy)
