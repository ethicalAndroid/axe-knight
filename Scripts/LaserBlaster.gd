class_name LaserBlaster extends Node2D

@export var pivot: Node2D
@export var sprite: Sprite2D
@export var ray: RayCast2D
@export var aim_timer: Timer
@export var charge_timer: Timer
@export var spend_timer: Timer
@export var beam: PackedScene
@export var danger: Line2D
@export var animator: AnimationPlayer

@export var sfx_aim: AudioStream
@export var sfx_charge: AudioStream
@export var sfx_blast: AudioStream

var target: Node2D
var direction: Vector2
var state: State = State.Idle

const LASER_DISTANCE = 3_000

enum State {
	Idle, Aiming, Charging, Spent
}

func SetTarget(given_target: Node2D):
	target = given_target

func StartAiming():
	danger.visible = true
	aim_timer.start()
	state = State.Aiming
	animator.stop()
	animator.queue("aim")
	Audio.Play(sfx_aim)

func StartCharging():
	charge_timer.start()
	state = State.Charging
	animator.stop()
	animator.queue("charge")
	Audio.Play(sfx_charge)

func FinishCharging():
	spend_timer.start()
	state = State.Spent

	Audio.Play(sfx_blast)
	animator.stop()
	animator.queue("blast")

	danger.visible = false

	var effect: LaserBeam = beam.instantiate()
	get_node(Fading.ROOT_PARENT).add_child(effect)
	effect.Create(self.global_position, self.global_position + ray.target_position)

	if ray.get_collider().is_class("CharacterBody2D"):
		var c: AxeKnight = ray.get_collider()
		c.OnHit(direction, false)

func StartIdle():
	state = State.Idle
	direction = Vector2.ZERO
	animator.stop()
	animator.queue("idle")


func _process(_delta: float) -> void:
	if (state == State.Aiming):
		direction = (target.global_position - self.global_position).normalized()
		ray.target_position = direction * LASER_DISTANCE
		danger.points[1] = ray.target_position
	if (direction):
		pivot.scale.y = sign(direction.x)
		pivot.rotation = Vector2.RIGHT.angle_to(direction)
