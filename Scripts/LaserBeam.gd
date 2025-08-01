class_name LaserBeam extends Line2D

@export var lifetime: float
@export var curve: Curve
@export var base_width: float

var life: float = 0

const ROOT_PARENT = "/root/Game/Trails"

func Create(pos: Vector2, aim: Vector2):
    points = [pos, aim]


func _process(delta: float) -> void:
    life += delta
    width = curve.sample(inverse_lerp(0, lifetime, life)) * base_width
    if (life > lifetime):
        queue_free()