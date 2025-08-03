class_name Summon extends Node2D

@export var summon: PackedScene
@export var sfx: AudioStream

var gravity: float

func GetVelocity() -> Vector2:
    return Vector2.ZERO

func Shoot():
    Audio.Play(sfx)
    var spawn: Projectile = summon.instantiate()
    get_node(Projectile.ROOT_PARENT).add_child(spawn)
    spawn.global_position = global_position
    spawn.Shoot(GetVelocity(), gravity)
    queue_free()