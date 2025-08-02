class_name Spin extends Node2D

@export var spins: Array[Node2D]
@export var speed: float

var v: float = 0

func _process(delta: float) -> void:
    v += delta
    for x in spins:
        x.rotation = v * speed