class_name LaserBlaster extends Node2D

@export var pivot: Node2D
@export var sprite: Sprite2D
@export var ray: RayCast2D
@export var aim_timer: Timer
@export var charge_timer: Timer
@export var spend_timer: Timer

var target: Node2D
var direction: Vector2
var state: State = State.Idle

const LASER_DISTANCE = 10_000

enum State {
	Idle, Aiming, Charging, Spent
}

func SetTarget(given_target: Node2D):
	target = given_target

func _ready(): # DEBUG
	StartAiming()

func StartAiming():
	aim_timer.start()
	state = State.Aiming

func StartCharging():
	charge_timer.start()
	state = State.Charging

func FinishCharging():
	spend_timer.start()
	state = State.Spent
	ray.get_collision_point()
	if ray.get_collider().is_class("CharacterBody2D"):
		ray.get_collider().call("OnHit", direction)

func StartIdle():
	state = State.Idle
	direction = Vector2.ZERO


func _process(_delta: float) -> void:
	if (state == State.Aiming):
		direction = (target.global_position - self.global_position).normalized()
		ray.target_position = direction * LASER_DISTANCE
	if (direction):
		pivot.scale.y = sign(direction.x)
		pivot.rotation = Vector2.RIGHT.angle_to(direction)
