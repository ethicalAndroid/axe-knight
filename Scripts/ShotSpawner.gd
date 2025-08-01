class_name ShotSpawner extends Node2D

@export var summon: PackedScene
@export var point: Node2D
@export var speed: float
@export var gravity: float
@export var add: Vector2

var target: Node2D
func SetTarget(given_target: Node2D):
    target = given_target
    
func Shoot():
    var spawn: SummonShot = summon.instantiate()
    get_node(Projectile.ROOT_PARENT).add_child(spawn)
    
    spawn.global_position = point.global_position
    spawn.target = target
    spawn.speed = speed
    spawn.gravity = gravity
    spawn.add = add
