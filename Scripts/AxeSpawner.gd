class_name AxeSpawner extends Node2D

@export var points: Array[Node2D]
@export var velocties: Array[Vector2]
@export var gravity: float
@export var timer: Timer
@export var summon_axe: PackedScene

var direction: float
var index: int = 0

var target: Node2D
func SetTarget(given_target: Node2D):
	target = given_target

func StartAttack(given_direction: float):
	if given_direction:
		direction = sign(given_direction)
	else:
		direction = 1
	OnTimerEnd()

func OnTimerEnd():
	if !(index < points.size()):
		index = 0
		return

	var spawn: SummonAxe = summon_axe.instantiate()
	get_node(Projectile.ROOT_PARENT).add_child(spawn)
	
	spawn.global_position = points[index].global_position
	var vel = velocties[index]
	vel.x *= direction
	spawn.velocity = vel
	spawn.gravity = gravity

	index += 1
	timer.start()
